module KintoBox
  class KintoRecord
    attr_reader :id
    def initialize (collection, record_id)
      raise ArgumentError if collection.nil? || record_id.nil?
      @kinto_client = collection.bucket.kinto_client
      @id = record_id
      @url_path = "/buckets/#{collection.bucket.id}/collections/#{collection.id}/records/#{@id}"
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

    def replace(data)
      @kinto_client.put(@url_path, {'data' => data})
    end
  end
end