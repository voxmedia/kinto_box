require 'kinto_box/kinto_collection'
require 'kinto_box/kinto_object'
require 'kinto_box/kinto_group'
module KintoBox
  class KintoBucket
    include KintoObject

    attr_accessor :id
    attr_reader :kinto_client

    def initialize (client, bucket_id)
      raise ArgumentError if bucket_id.nil? || client.nil?

      @kinto_client = client
      @id = bucket_id
      @url_path = "/buckets/#{@id}"
    end

    def list_collections
      @kinto_client.get("#{@url_path}/collections")
    end

    def list_groups
      @kinto_client.get("#{@url_path}/groups")
    end

    def collection (collection_id)
      @collection = KintoCollection.new(self, collection_id)
      @collection
    end

    def group(group_id)
      @group = KintoGroup.new(self, group_id)
      @group
    end

    def create_collection(collection_id)
      @kinto_client.post("#{@url_path}/collections", { 'data' => { 'id' => collection_id}})
      collection(collection_id)
    end

    def create_group(group_id, members)
      members = [members] unless members.is_a?(Array)
      @kinto_client.put("#{@url_path}/groups/#{group_id}", { 'data' => { 'members' => members}})
      group(group_id)
    end

    def delete_collections
      @kinto_client.delete("#{@url_path}/collections")
    end
  end
end