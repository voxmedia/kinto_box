require "kinto_box/version"
require 'httparty'
require 'api_errors'

module KintoBox
  class KintoClient
    include HTTParty
    headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    attr_accessor :default_bucket

    def initialize(server, options = nil)
      @server = server
      self.class.base_uri URI.join(@server, '/v1/').to_s

      @auth = {username: options[:username],
               password: options[:password] } unless options.nil?

      @auth = ENV['KINTO_API_TOKEN'] unless ENV['KINTO_API_TOKEN'].nil?
    end

    def serverInfo
      get '/'
    end

    def get(path)
      ResponseHandler.handle self.class.get(path)
    end
  end
end
