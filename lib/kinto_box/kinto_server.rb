require 'kinto_box/kinto_bucket'
module KintoBox
  class KintoServer < KintoObject
    child_class KintoBox::KintoBucket

    alias_method :bucket, :child

    alias_method :list_buckets, :list_children
    alias_method :delete_buckets, :delete_children
    alias_method :count_buckets, :count_children

    alias_method :create_bucket_request, :create_child_request
    alias_method :list_bucket_request, :list_children_request
    alias_method :delete_buckets_request, :delete_children_request
    alias_method :count_buckets_request, :count_children_request

    def url_path
      '/'
    end

    # Get current user id
    # @return [String] current user id
    def current_user_id
      info['user']['id']
    end

    def create_bucket(id)
      create_child(id: id)
    end
  end
end
