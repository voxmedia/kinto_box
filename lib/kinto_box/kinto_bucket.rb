require 'kinto_box/kinto_collection'
require 'kinto_box/kinto_group'
module KintoBox
  class KintoBucket < KintoObject
    child_class KintoCollection

    alias_method :collection, :child

    alias_method :list_collections, :list_children
    alias_method :delete_collections, :delete_children
    alias_method :count_collections, :count_children

    alias_method :create_collection_request, :create_child_request
    alias_method :list_collections_request, :list_children_request
    alias_method :delete_collections_request, :delete_children_request
    alias_method :count_collections_request, :count_children_request

    def group(group_id)
      KintoGroup.new(id: group_id, parent: self)
    end

    def list_groups
      @client.get("#{url_path}/groups")
    end

    def create_group(group_id, members)
      members = [members] unless members.is_a?(Array)
      resp = @client.put("#{url_path}/groups/#{group_id}", 'data' => { 'members' => members })
      KintoGroup.new(parent: self, info: resp)
    end

    def delete_groups
      @client.delete("#{url_path}/groups")
    end

    def create_collection(id)
      create_child(id: id)
    end
  end
end
