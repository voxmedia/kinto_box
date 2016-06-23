module KintoBox
  class KintoBucket
    attr_accessor :id

    def initialize (client, bucket_id)
      @kinto_client = client
      raise ArgumentError if bucket_id.nil?
      @id = bucket_id
    end

    def info
      @kinto_client.get("/buckets/#{@id}")
    end
  end
end