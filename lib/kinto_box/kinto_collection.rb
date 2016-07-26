require 'kinto_box/kinto_record'
require 'kinto_box/kinto_object'

module KintoBox
  class KintoCollection
    include KintoObject

    attr_accessor :id
    attr_reader :bucket

    def initialize (bucket, collection_id)
      raise ArgumentError if bucket.nil? || collection_id.nil?
      @kinto_client = bucket.kinto_client
      @bucket = bucket
      @id = collection_id
      @url_path = "/buckets/#{bucket.id}/collections/#{@id}"
    end

    def record (record_id, return_ref = false)
      record = KintoRecord.new(self, record_id)
      return record if return_ref
      record.info
    end

    def list_records(filters = nil, sort = nil)
      query_string = '?'
      query_string += filters unless filters.nil?
      query_string += '&' unless filters.nil? || sort.nil?
      query_string += "_sort=#{sort}" unless sort.nil?
      path = query_string == '?' ? "#{@url_path}/records" : "#{@url_path}/records#{query_string}"
      @kinto_client.get(path)
    end

    def create_record(data)
      resp = @kinto_client.post("#{@url_path}/records", { 'data' => data})
      record_id = resp['data']['id']
      record(record_id, true)
    end

    def delete_records
      @kinto_client.delete("#{@url_path}/records")
    end
  end
end