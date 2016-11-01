require 'kinto_box/kinto_record'
require 'kinto_box/kinto_object'
require 'kinto_box/kinto_batch_request'

module KintoBox
  class KintoCollection < KintoObject


    attr_reader :bucket

    def initialize (bucket, collection_id)
      raise ArgumentError if bucket.nil? || collection_id.nil?
      @kinto_client = bucket.kinto_client
      @bucket = bucket
      @id = collection_id
      @url_path = "/buckets/#{bucket.id}/collections/#{@id}"
      @child_path = '/records'
    end

    def record (record_id)
      KintoRecord.new(self, record_id)
    end


    def list_records(filters = nil, sort = nil)
      @kinto_client.get(url_w_qsp(filters, sort))
    end


    def create_record(data)
      resp = @kinto_client.post("#{@url_path}#{@child_path}", { 'data' => data})
      record_id = resp['data']['id']
      record(record_id)
    end


    def delete_records(filters = nil)
      @kinto_client.delete(url_w_qsp(filters))
    end


    def count_records(filters = nil)
      @kinto_client.head(url_w_qsp(filters))['Total-Records'].to_i
    end


    alias_method :create_record_request, :create_child_request
    alias_method :list_records_request, :list_children_request
    alias_method :delete_records_request, :delete_children_request
    alias_method :count_records_request, :count_children_request
  end
end