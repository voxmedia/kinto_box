module KintoBox
  class KintoBucket
    attr_accessor :id

    def initialize (client, bucket_id)
      @kinto_client = client
      raise ArgumentError if bucket_id.nil?
      @id = bucket_id
      @url_path = "/buckets/#{@id}"
    end

    def info
      @kinto_client.get(@url_path)
    end

    def delete
      @kinto_client.delete(@url_path)
    end
  end
end