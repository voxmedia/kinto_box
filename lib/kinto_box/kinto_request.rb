module KintoBox
  class KintoRequest

    def initialize(method = 'GET', path = nil , body = {}, headers = nil)
      @method = method
      @path = path
      @body = body
      @headers = headers
    end

    def hashed_object
      { 'method' => @method,
        'path' => @path,
        'body' => @body
      }
    end
  end
end