require 'test_helper'

class KintoBoxTest < Minitest::Test
  def setup
    default_kinto_client.create_bucket('TestBucket1')
    test_bucket.create_collection('TestCollection1')
    test_bucket.create_group('TestGroup1', 'TestUser1')
    test_collection.delete_records
    test_collection.create_record('foo' => 'testval')
  end

  def test_that_it_has_a_version_number
    refute_nil ::KintoBox::VERSION
  end

  def test_get_server_info
    resp = default_kinto_client.server_info
    assert_equal resp['project_name'], 'kinto'
    assert_equal resp['url'], URI.join(KINTO_SERVER, '/v1/').to_s
  end

  def test_get_server_info_w_auth
    kinto_client = KintoBox.new(KINTO_SERVER, username: 'token', password: 'my-secret')
    resp = kinto_client.server_info
    assert_equal resp['project_name'], 'kinto'
    assert_equal resp['url'], URI.join(KINTO_SERVER, '/v1/').to_s
  end

  def test_non_existent_server
    kinto_client = KintoBox.new('http://kavyasukumar.com')

    assert_raises KintoBox::NotFound do
      kinto_client.server_info
    end
  end

  def test_list_buckets
    resp = default_kinto_client.list_buckets
    assert resp['data'].count >= 1
  end

  def test_create_delete_bucket
    random_name = random_string
    bucket = default_kinto_client.create_bucket(random_name)
    assert_equal bucket.info['data']['id'], random_name
    assert bucket.exists?
    bucket.delete
    refute bucket.exists?
  end

  def test_bucket_exists
    assert test_bucket.exists?
    refute default_kinto_client.bucket('nonexistent').exists?
  end

  def test_get_bucket_info
    bucket = default_kinto_client.bucket('TestBucket1').info
    assert_equal bucket['data']['id'], 'TestBucket1'
  end

  def test_create_delete_collection
    collection_id = random_string
    collection = test_bucket.create_collection(collection_id)
    assert_equal collection.info['data']['id'], collection_id
    assert collection.exists?
    collection.delete
    refute collection.exists?
  end

  def test_collection_exists
    assert test_collection.exists?
    refute test_bucket.collection('nonexistent').exists?
  end

  def test_get_collection_info
    collection = test_bucket.collection('TestCollection1').info
    assert_equal collection['data']['id'], 'TestCollection1'
  end

  def test_update_collection
    value = random_string
    collection = test_bucket.collection('TestCollection1')
    collection.update('property1' => value)
    assert_equal collection.info['data']['property1'], value
  end

  def test_create_delete_record
    value = random_string
    record = test_collection.create_record('foo' => value)
    assert_equal record.info['data']['foo'], value
    record.delete
  end

  def test_get_all_records
    resp = test_collection.list_records
    assert resp['data'].count >= 1
  end

  def test_count_records
    count = test_collection.count_records
    resp = test_collection.list_records
    assert_equal resp['data'].count, count
  end

  def test_count_records_filtered
    foo_val = random_string
    test_collection.create_record('foo' => foo_val)
    test_collection.create_record('foo' => foo_val)
    foo_val_2 = random_string
    test_collection.create_record('foo' => foo_val_2)
    count = test_collection.count_records("foo=#{foo_val}")
    records = test_collection.list_records("foo=#{foo_val}")
    assert_equal records['data'].count, count
  end

  def test_create_update_record
    value = random_string
    record = test_collection.create_record('foo' => value)
    assert_equal record.info['data']['foo'], value

    new_value = random_string
    record.update('bar' => new_value)
    assert_equal record.info['data']['foo'], value
    assert_equal record.info['data']['bar'], new_value

    record.delete
  end

  def test_create_replace_record
    value = random_string
    record = test_collection.create_record({'foo' => value})
    assert_equal record.info['data']['foo'], value

    new_value = random_string
    record.replace('foo' => new_value)
    assert_equal record.info['data']['foo'], new_value

    record.delete
  end

  def test_change_collection_read_permission
    collection_name = random_string
    collection = test_bucket.create_collection(collection_name)
    collection.add_permission('everyone', 'read')
    assert_equal collection.permissions['read'], ['system.Everyone']
    collection.delete
  end

  def test_delete_all_collections
    test_bucket.create_collection(random_string)
    test_bucket.create_collection(random_string)
    test_bucket.delete_collections
    assert_empty test_bucket.list_collections['data']
  end

  def test_delete_all_records
    test_collection.create_record('foo' => random_string)
    test_collection.create_record('foo' => random_string)
    test_collection.delete_records
    assert_empty test_collection.list_records['data']
  end

  def test_filtered_record_delete
    foo_val = random_string
    test_collection.create_record('foo' => foo_val)
    test_collection.create_record('foo' => foo_val)

    test_collection.delete_records("foo=#{foo_val}")
    assert_equal 0, test_collection.count_records("foo=#{foo_val}")
  end

  def test_create_delete_group
    group_name = random_string
    member = random_string
    group = test_bucket.create_group(group_name, member)
    assert_equal group.info['data']['id'], group_name
    assert_equal group.info['data']['members'][0], member
    group.delete
  end

  def test_add_remove_group_member
    user = random_string
    test_group.add_member(user)
    assert test_group.info['data']['members'].include? user
    test_group.remove_member(user)
    assert !test_group.info['data']['members'].include?(user)
  end

  def test_filter_records
    foo_val = random_string
    test_collection.create_record('foo' => foo_val)
    records = test_collection.list_records("foo=#{foo_val}")
    assert_equal records.length, 1
    assert_equal records['data'][0]['foo'], foo_val
  end

  def test_sort_records
    test_collection.delete_records
    record1 = test_collection.create_record('val' => 10)
    record2 = test_collection.create_record('val' => 11)
    records = test_collection.list_records(nil, 'val')

    assert_equal records['data'][0]['val'], 10
    assert_equal records['data'][1]['val'], 11

    # descending sort and filter
    records = test_collection.list_records('min_val=10', '-val')
    assert_equal records['data'][0]['val'], 11
    assert_equal records['data'][1]['val'], 10
    record1.delete
    record2.delete
  end

  def test_raw_get
    resp = default_kinto_client.get('/buckets/TestBucket1')
    assert_equal resp['data']['id'], 'TestBucket1'
  end

  def test_batch_request
    test_collection.delete_records
    record = test_collection.create_record('val' => random_string)
    value = random_string
    resp = default_kinto_client.batch do |req|
      req.add_request(test_collection.create_record_request('val' => value))
      req.add_request(test_collection.create_record_request('val' => random_string))
      req.add_request(test_collection.delete_records_request("val=#{value}"))
      req.add_request(test_collection.count_records_request)
      req.add_request(record.delete_request)
      req.add_request(test_collection.count_records_request)
    end

    assert_equal 6, resp['responses'].length
    assert_equal 2, resp['responses'][3]['headers']['Total-Records'].to_i
    assert_equal 1, resp['responses'][5]['headers']['Total-Records'].to_i
  end

  def test_batch_request_2
    value = random_string
    resp = default_kinto_client
           .create_batch_request
           .add_request(test_bucket.create_collection_request('id' => value))
           .execute
    assert_equal 1, resp['responses'].length
    assert_equal 201, resp['responses'][0]['status']
  end

  private

  def default_kinto_client
    KintoBox.new(KINTO_SERVER)
  end

  def test_bucket
    default_kinto_client.bucket('TestBucket1')
  end

  def test_collection
    test_bucket.collection('TestCollection1')
  end

  def test_group
    test_bucket.group('TestGroup1')
  end
end
