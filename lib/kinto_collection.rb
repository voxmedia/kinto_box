module KintoBox
  class KintoCollection
    def initialize (bucket, collection_id)
      raise ArgumentError if bucket.nil? || collection_id.nil?
      @kinto_client = bucket.kinto_client
      @id = collection_id
      @url_path = "/buckets/#{bucket.id}/collections/#{@id}"
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
  end
end