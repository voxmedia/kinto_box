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
end
