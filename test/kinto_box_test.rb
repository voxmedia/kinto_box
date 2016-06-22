require 'test_helper'

class KintoBoxTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::KintoBox::VERSION
  end

  def test_get_server_info
    kinto_client = KintoBox::KintoClient.new('https://kintobox.herokuapp.com', nil)
    resp = kinto_client.serverInfo
    assert_equal resp['project_name'], 'kinto'
    assert_equal resp['url'], 'https://kintobox.herokuapp.com/v1/'
  end

  def test_get_server_info_w_auth
    kinto_client = KintoBox::KintoClient.new('https://kintobox.herokuapp.com', {:username => 'test', :password => 'my-secret'})
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
end

