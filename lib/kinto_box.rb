require "kinto_box/version"
require 'httparty'
require 'response_handler'
require 'kinto_bucket'
require 'base64'

module KintoBox
  class KintoClient
    include HTTParty
    headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    def initialize(server, options = nil)
      @server = server
      self.class.base_uri URI.join(@server, '/v1/').to_s

      unless options.nil? || options[:username].nil? || options[:password].nil?
        @auth = Base64.encode64("#{options[:username]}:#{options[:password]}")
      end

      @auth = ENV['KINTO_API_TOKEN'] if @auth.nil?
      self.class.headers('Authorization' => "Basic #{@auth}")
    end

    def bucket (bucket_id)
      @bucket = KintoBucket.new(self, bucket_id)
      @bucket
    end

    def server_info
      get '/'
    end

    # buckets
    def list_buckets
      get '/buckets'
    end

    def create_bucket(bucket_id)
      put "/buckets/#{bucket_id}"
      bucket(bucket_id)
    end

    def delete_buckets
      delete '/buckets'
    end

    def put(path, data = {})
      ResponseHandler.handle self.class.put(path, :body => data.to_json)
    end

    def post(path, data = {})
      ResponseHandler.handle self.class.post(path, :body => data.to_json)
    end

    def patch(path, data)
      ResponseHandler.handle self.class.patch(path, :body => data.to_json)
    end

    def delete(path)
      ResponseHandler.handle self.class.delete(path)
    end

    def get(path)
      ResponseHandler.handle self.class.get(path)
    end
  end
end
