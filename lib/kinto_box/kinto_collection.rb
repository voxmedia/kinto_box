require 'kinto_box/kinto_record'
module KintoBox
  class KintoCollection < KintoObject
    child_class KintoRecord

    alias_method :bucket, :parent
    alias_method :record, :child

    alias_method :create_record, :create_child
    alias_method :list_records, :list_children
    alias_method :delete_records, :delete_children
    alias_method :count_records, :count_children

    alias_method :create_record_request, :create_child_request
    alias_method :list_records_request, :list_children_request
    alias_method :delete_records_request, :delete_children_request
    alias_method :count_records_request, :count_children_request
  end
end
