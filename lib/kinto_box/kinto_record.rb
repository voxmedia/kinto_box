require 'kinto_box/kinto_object'
module KintoBox
  class KintoRecord
    include KintoObject
    attr_reader :id
    def initialize (collection, record_id)
      raise ArgumentError if collection.nil? || record_id.nil?
      @kinto_client = collection.bucket.kinto_client
      @id = record_id
      @url_path = "/buckets/#{collection.bucket.id}/collections/#{collection.id}/records/#{@id}"
    end

    def replace(data)
      @kinto_client.put(@url_path, {'data' => data})
    end
  end
end