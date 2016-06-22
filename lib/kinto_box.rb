require "kinto_box/version"
require 'httparty'
require 'api_errors'

module KintoBox
  class KintoClient
    include HTTParty
    headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

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
      handle_response self.class.get(path)
    end

    def handle_response(resp)
      if [200, 201].include? resp.code
        JSON.parse resp.body
      elsif [202, 204].include? resp.code
        true
      elsif resp.code == 400
        raise BadRequest, resp
      elsif resp.code == 404
        raise NotFound, resp
      elsif resp.code == 401
        raise NotAllowed, resp
      elsif resp.code >= 500
        raise ServerError, resp
      else
        raise Error, resp
      end
    end
  end
end
