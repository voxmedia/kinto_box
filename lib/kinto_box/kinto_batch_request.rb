require 'kinto_box/kinto_collection'
require 'kinto_box/kinto_object'
require 'kinto_box/kinto_request'

module KintoBox
  class KintoBatchRequest

    def initialize(kinto_client)
      @kinto_client = kinto_client
      @request_data = {'defaults' => {
                        'method'=> 'POST',
                        'path'=> '/'
                       },
                       'requests' =>[]
      }
      @requests = @request_data['requests']
    end

    def add_request(request)
        @requests.push(request.hashed_object)
        self
    end

    def send

      @kinto_client.post('/batch', @request_data)
    end

  end
end