require 'kinto_box/kinto_request'
module KintoBox
  class KintoBatchRequest < KintoRequest
    attr_reader :requests

    def initialize(client)
      @requests = []
      super(client, 'POST', '/batch')
    end

    def add_request(request)
      requests.push(request.to_hash)
      self
    end

    def body
      {
        'defaults' => {
          'method' => 'POST',
          'path' => '/'
        },
        'requests' => requests
      }
    end
  end
end
