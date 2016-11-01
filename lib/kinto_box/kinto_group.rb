require 'kinto_box/kinto_object'

module KintoBox
  class KintoGroup < KintoObject

    attr_accessor :id
    attr_reader :bucket

    def initialize (bucket, group_id)
      raise ArgumentError if bucket.nil? || group_id.nil?
      @kinto_client = bucket.kinto_client
      @bucket = bucket
      @id = group_id
      @url_path = "/buckets/#{bucket.id}/groups/#{@id}"
    end

    def update_members(members)
      members = [members] unless members.is_a?(Array)
      update({ 'members' => members })
    end

    def add_member(member)
      members = info['data']['members']
      members << member
      update({ 'members' => members })
    end

    def remove_member(member)
      members = info['data']['members']
      members.delete(member)
      update({ 'members' => members })
    end
  end
end