require 'kinto_collection'
module KintoBox
  class KintoBucket
    attr_accessor :id
    attr_reader :kinto_client

    def initialize (client, bucket_id)
      raise ArgumentError if bucket_id.nil? || client.nil?

      @kinto_client = client
      @id = bucket_id
      @url_path = "/buckets/#{@id}"
    end

    def collection (collection_id)
      @collection = KintoCollection.new(self, collection_id)
      @collection
    end

    def info
      @kinto_client.get(@url_path)
    end

    def delete
      @kinto_client.delete(@url_path)
    end

    def update(data)
      @kinto_client.patch(@url_path, {'data' => data})
    end

    def create_collection(collection_id)
      @kinto_client.post("#{@url_path}/collections", { 'data' => { 'id' => collection_id}})
      collection(collection_id)
    end
  end
end