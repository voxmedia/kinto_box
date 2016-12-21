require 'kinto_box/kinto_object'
module KintoBox
  class KintoGroup < KintoObject
    def update_members(members)
      members = [members] unless members.is_a?(Array)
      update 'members' => members
    end

    def add_member(member)
      members = info['data']['members']
      members << member
      update 'members' => members
    end

    def remove_member(member)
      members = info['data']['members']
      members.delete(member)
      update 'members' => members
    end
  end
end
