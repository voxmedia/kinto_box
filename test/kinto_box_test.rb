require 'test_helper'

class KintoBoxTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::KintoBox::VERSION
  end

  def test_get_server_info
    kinto_client = default_kinto_client
    resp = kinto_client.serverInfo
    assert_equal resp['project_name'], 'kinto'
    assert_equal resp['url'], 'https://kintobox.herokuapp.com/v1/'
  end

  def test_get_server_info_w_auth
    kinto_client = KintoBox::KintoClient.new(KINTO_SERVER, {:username => 'token', :password => 'my-secret'})
    resp = kinto_client.serverInfo
    assert_equal resp['project_name'], 'kinto'
    assert_equal resp['url'], 'https://kintobox.herokuapp.com/v1/'
  end

  def test_non_existent_server
    kinto_client = KintoBox::KintoClient.new('http://kavyasukumar.com')

    assert_raises KintoBox::NotFound do
      resp = kinto_client.serverInfo
    end
  end

  def test_get_bucket_info
    bucket = default_kinto_client.bucket('TestBucket1').info
    assert_equal bucket['data']['id'], 'TestBucket1'
  end

  private

  def default_kinto_client
    KintoBox::KintoClient.new(KINTO_SERVER)
  end
end

