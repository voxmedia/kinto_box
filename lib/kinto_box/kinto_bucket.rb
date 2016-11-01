require 'kinto_box/kinto_collection'
require 'kinto_box/kinto_object'
require 'kinto_box/kinto_group'
module KintoBox
  class KintoBucket < KintoObject

    attr_reader :kinto_client

    def initialize (client, bucket_id)
      raise ArgumentError if bucket_id.nil? || client.nil?

      @kinto_client = client
      @id = bucket_id
      @url_path = "/buckets/#{@id}"
      @child_path = '/collections'
    end

    def list_collections(filters = nil, sort = nil)
      @kinto_client.get(url_w_qsp(filters, sort))
    end

    def list_groups
      @kinto_client.get("#{@url_path}/groups")
    end

    def collection (collection_id)
      @collection = KintoCollection.new(self, collection_id)
    end

    def group(group_id)
      @group = KintoGroup.new(self, group_id)
    end

    def create_collection(collection_id)
      @kinto_client.post("#{@url_path}#{@child_path}", { 'data' => { 'id' => collection_id}})
      collection(collection_id)
    end

    def create_group(group_id, members)
      members = [members] unless members.is_a?(Array)
      @kinto_client.put("#{@url_path}/groups/#{group_id}", { 'data' => { 'members' => members}})
      group(group_id)
    end

    def delete_collections
      @kinto_client.delete(url_w_qsp)
    end

    def delete_groups
      @kinto_client.delete("#{@url_path}/groups")
    end

    def count_collections(filters = nil)
      @kinto_client.head(url_w_qsp(filters))['Total-Records'].to_i
    end
  end
end