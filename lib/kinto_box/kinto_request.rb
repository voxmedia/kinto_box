module KintoBox
  class KintoRequest
    attr_reader :method, :path, :body, :headers

    def initialize(client, method, path, body = {}, headers: nil)
      @client = client
      @method = method
      @path = path
      @body = body
      @headers = headers
    end

    def to_hash
      { 'method' => method, 'path' => path, 'body' => body }
    end

    def execute
      @client.send_request(self)
    end
  end
end
