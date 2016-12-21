require 'httparty'
require 'base64'

require 'kinto_box/version'
require 'kinto_box/errors'
require 'kinto_box/kinto_server'
require 'kinto_box/kinto_batch_request'

module KintoBox
  # Initializes a new Kinto client.
  #
  # @param [String] server Url of the server without the version
  # @param [Hash] options Optional parameter. If the hash contains :username
  #                       and :password, it will be used to authenticate.
  #                       `options` parameter Can be used to pass in
  #                       credentials. If no credentials are passed, it looks
  #                       for KINTO_API_TOKEN environment variable.
  # @return [KintoBox::KintoClient] A kinto client object
  def self.new(*args, **kwargs, &blk)
    KintoClient.new(*args, **kwargs, &blk)
  end

  class KintoClient
    include HTTParty
    headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    # Initializes a new Kinto client.
    #
    # @param [String] server Url of the server without the version
    # @param [Hash] options Optional parameter. If the hash contains :username
    #                       and :password, it will be used to authenticate.
    #                       `options` parameter Can be used to pass in
    #                       credentials. If no credentials are passed, it looks
    #                       for KINTO_API_TOKEN environment variable.
    # @return [KintoBox::KintoClient] A kinto client object
    def initialize(server, username: nil, password: nil)
      self.class.base_uri(URI.join(server, '/v1/').to_s)

      auth = if username && password
               Base64.encode64("#{username}:#{password}")
             else
               ENV['KINTO_API_TOKEN']
             end

      self.class.headers('Authorization' => "Basic #{auth}")

      @server = KintoServer.new(client: self)
    end

    # Get reference to a bucket
    #
    # @param [String] bucket_id The id of the bucket
    # @return [KintoBox::KintoBucket] A kinto bucket object
    def bucket(bucket_id)
      @server.bucket(bucket_id)
    end

    # Get server information
    #
    # @return [Hash] Server info as a hash
    def server_info
      @server.info
    end

    # Get current user id
    #
    # @return [String] current user id
    def current_user_id
      @server.current_user_id
    end

    # List of buckets
    #
    # @return [Hash] with list of buckets
    def list_buckets
      @server.list_buckets
    end

    # Create a bucket
    #
    # @param [String] bucket_id The id of the bucket
    # @return [KintoBox::KintoBucket] A kinto bucket object
    def create_bucket(bucket_id)
      @server.create_bucket(bucket_id)
    end

    # Delete all buckets
    # @return [Hash] API response
    def delete_buckets
      @server.delete_buckets
    end

    # Calls http PUT on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def put(path, data = {})
      request 'PUT', path, body: data.to_json
    end

    # Calls http POST on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def post(path, data = {})
      request 'POST', path, body: data.to_json
    end

    # Calls http PATCH on path
    #
    # @params [String]path Url path
    # @params [Hash] data to be sent in the body
    # @return [Hash] response body
    def patch(path, data)
      request 'PATCH', path, body: data.to_json
    end

    # Calls http DELETE on path
    #
    # @params [String]path Url path
    # @return [Hash] response body
    def delete(path)
      request 'DELETE', path
    end

    # Calls http GET on path
    #
    # @params [String]path Url path
    # @return [Hash] response body
    def get(path)
      request 'GET', path
    end

    # Calls http HEAD on path
    #
    # @params [String]path Url path
    # @return [Hash] response body
    def head(path)
      request 'HEAD', path
    end

    # Get a request object
    # @param [String] method
    # @param [String] path
    # @param [Hash] body
    # @return [KintoRequest] Request object
    def create_request(method, path, body = {})
      KintoRequest.new self, method, path, body
    end

    # Make batch requests
    # @return [KintoBatchRequest] New back request object
    def create_batch_request
      KintoBatchRequest.new self
    end

    # Make batch requests
    #   results = client.batch do req
    #               req.add_request(...)
    #             end
    def batch
      req = create_batch_request
      if block_given?
        yield req
        req.execute
      else
        req
      end
    end

    # Send a prepared request
    # @param [KintoRequest] request
    # @return [Hash] response
    def send_request(request_obj)
      request(request_obj.method, request_obj.path, body: request_obj.body.to_json)
    end

    private

    # Handle all the kinds of requests
    #
    # @param [String] HTTP method
    # @param [String] Path to query
    # @return [Hash] Return data
    def request(method, path, **kwargs)
      verbs = %w(put get post delete options head move copy patch)
      method = method.to_s.downcase
      raise HTTPBadRequest("Unsupported HTTP method #{method}") unless verbs.include?(method)
      resp = self.class.send(method.to_sym, path, **kwargs)
      if method == 'head'
        handle_response resp, head_instead: true
      else
        handle_response resp
      end
    end

    # Parse and process HTTP response. Check for codes, and parse return body.
    # @param [Object] Response object
    # @param [Boolean] <head_instead> Return headers instead of body
    # @return [Hash] Response payload
    def handle_response(resp, head_instead: false)
      case resp.code
      when 200, 201
        head_instead ? resp.headers : JSON.parse(resp.body)
      when 202, 204
        true
      when 400
        raise BadRequest, resp
      when 401
        raise NotAllowed, resp
      when 403
        raise NotAuthorized, resp
      when 404
        raise NotFound, resp
      else
        if resp.code >= 500
          raise ServerError, resp
        else
          raise Error, resp
        end
      end
    end
  end
end
