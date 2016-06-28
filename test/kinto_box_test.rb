require 'test_helper'

class KintoBoxTest < Minitest::Test
  def setup
    default_kinto_client.create_bucket('TestBucket1')
    test_bucket.create_collection('TestCollection1')
    test_collection.create_record({'foo' => 'testval'})
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
    kinto_client = KintoBox::KintoClient.new(KINTO_SERVER, {:username => 'token', :password => 'my-secret'})
    resp = kinto_client.server_info
    assert_equal resp['project_name'], 'kinto'
    assert_equal resp['url'], URI.join(KINTO_SERVER, '/v1/').to_s
  end

  def test_non_existent_server
    kinto_client = KintoBox::KintoClient.new('http://kavyasukumar.com')

    assert_raises KintoBox::NotFound do
      resp = kinto_client.server_info
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
    bucket.delete
    assert_raises KintoBox::NotAuthorized do
       bucket.info
    end
  end

  def test_get_bucket_info
    bucket = default_kinto_client.bucket('TestBucket1').info
    assert_equal bucket['data']['id'], 'TestBucket1'
  end

  def test_create_delete_collection
    collection_id = random_string
    collection = test_bucket.create_collection(collection_id)
    assert_equal collection.info['data']['id'], collection_id
    collection.delete
    assert_raises KintoBox::NotFound do
      collection.info
    end
  end

  def test_get_collection_info
    collection = test_bucket.collection('TestCollection1').info
    assert_equal collection['data']['id'], 'TestCollection1'
  end

  def test_update_collection
    value = random_string
    collection = test_bucket.collection('TestCollection1')
    collection.update({'property1' => value })
    assert_equal collection.info['data']['property1'], value
  end

  def test_create_delete_record
    value = random_string
    record = test_collection.create_record({'foo' => value})
    assert_equal record.info['data']['foo'], value
    record.delete
  end

  def test_get_all_records
    resp = test_collection.list_records
    assert resp['data'].count >= 1
  end

  def test_create_update_record
    value = random_string
    record = test_collection.create_record({'foo' => value})
    assert_equal record.info['data']['foo'], value

    new_value = random_string
    record.update({'bar' => new_value})
    assert_equal record.info['data']['foo'], value
    assert_equal record.info['data']['bar'], new_value

    record.delete
  end

  def test_create_replace_record
    value = random_string
    record = test_collection.create_record({'foo' => value})
    assert_equal record.info['data']['foo'], value

    new_value = random_string
    record.replace({'foo' => new_value})
    assert_equal record.info['data']['foo'], new_value

    record.delete
  end

  def test_change_collection_read_permission
    collection_name = random_string
    collection = test_bucket.create_collection(collection_name)
    collection.add_permission('everyone','read')
    assert_equal collection.permissions['read'], ['system.Everyone']
    collection.delete
  end


  private

  def default_kinto_client
    KintoBox::KintoClient.new(KINTO_SERVER)
  end

  def test_bucket
    default_kinto_client.bucket('TestBucket1')
  end

  def test_collection
    test_bucket.collection('TestCollection1')
  end
end

