require "kinto_box/version"
require 'httparty'
require 'kinto_box/response_handler'
require 'kinto_box/kinto_bucket'
require 'base64'

module KintoBox

  # Initializes a new Kinto client.
  #
  # @param [String] server Url of the server without the version
  # @param [Hash] options Optional parameter. If the hash contains :username and :password, it will be used to authenticate.
  # `options` parameter can be used to pass in credentials. If no credentials are passed, it looks for KINTO_API_TOKEN environment variable
  # @return [KintoBox::KintoClient] A kinto client object
  def KintoBox.new(server, options = nil)
    return KintoClient.new(server, options)
  end

  class KintoClient
    include HTTParty
    headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    # Initializes a new Kinto client.
    #
    # @param [String] server Url of the server without the version
    # @param [Hash] options Optional parameter. If the hash contains :username and :password, it will be used to authenticate.
    # `options` parameter can be used to pass in credentials. If no credentials are passed, it looks for KINTO_API_TOKEN environment variable
    # @return [KintoBox::KintoClient] A kinto client object
    def initialize(server, options = nil)
      @server = server
      self.class.base_uri URI.join(@server, '/v1/').to_s

      unless options.nil? || options[:username].nil? || options[:password].nil?
        @auth = Base64.encode64("#{options[:username]}:#{options[:password]}")
      end

      @auth = ENV['KINTO_API_TOKEN'] if @auth.nil?
      self.class.headers('Authorization' => "Basic #{@auth}")
    end

    # Get reference to a bucket
    #
    # @param [String] bucket_id The id of the bucket
    # @return [KintoBox::KintoBucket] A kinto bucket object
    def bucket (bucket_id)
      @bucket = KintoBucket.new(self, bucket_id)
      @bucket
    end

    # Get server information
    #
    # @return [Hash] Server info as a hash
    def server_info
      get '/'
    end

    # Get current user id
    #
    # @return [String] current user id
    def current_user_id
      server_info['user']['id']
    end

    # List of buckets
    #
    # @return [Hash] with list of buckets
    def list_buckets
      get '/buckets'
    end

    # Create a bucket
    #
    # @param [String] bucket_id The id of the bucket
    # @return [KintoBox::KintoBucket] A kinto bucket object
    def create_bucket(bucket_id)
      put "/buckets/#{bucket_id}"
      bucket(bucket_id)
    end

    # Delete all buckets
    #
    def delete_buckets
      delete '/buckets'
    end

    # Calls http PUT on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def put(path, data = {})
      ResponseHandler.handle self.class.put(path, :body => data.to_json)
    end

    # Calls http POST on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def post(path, data = {})
      ResponseHandler.handle self.class.post(path, :body => data.to_json)
    end

    # Calls http PATCH on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def patch(path, data)
      ResponseHandler.handle self.class.patch(path, :body => data.to_json)
    end

    # Calls http DELETE on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def delete(path)
      ResponseHandler.handle self.class.delete(path)
    end

    # Calls http GET on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def get(path)
      ResponseHandler.handle self.class.get(path)
    end

    # Calls http HEAD on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def head(path, data = {})
      ResponseHandler.get_response_head self.class.head(path)
    end
  end
end
