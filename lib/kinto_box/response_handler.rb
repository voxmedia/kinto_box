module KintoBox
  # Base exception class for all API Client exceptions
  class Error < StandardError
    attr_reader :response, :data
    def initialize(response)
      @response = response
      @data ||= begin
        JSON.parse(response.body)
      rescue
        {}
      end

      super("#{response.code} #{response.request.uri} #{response.body}")
    end
  end

  # Raised when there was something wrong with the request
  class BadRequest < Error; end

  # Raised when the authentication information is incorrect or incomplete
  class NotAllowed < Error; end

  # Raised when the requested thing is not found
  class NotFound < Error; end

  # Raised when the user is not authorized
  class NotAuthorized < Error; end

  # Raised when there is some sort of error on the server
  class ServerError < Error; end

  class ResponseHandler
    def self.handle(resp)
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
      elsif resp.code == 403
        raise NotAuthorized, resp
      elsif resp.code >= 500
        raise ServerError, resp
      else
        raise Error, resp
      end
    end

    def self.get_response_head(resp)
      if [200, 201].include? resp.code
        resp.headers
      else
        raise BadRequest, resp
      end
    end
  end
end
