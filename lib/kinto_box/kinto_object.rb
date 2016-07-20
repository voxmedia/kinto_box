module KintoBox
  module KintoObject
    def info
      @kinto_client.get(@url_path)
    end

    def delete
      @kinto_client.delete(@url_path)
    end

    def update(data)
      @kinto_client.patch(@url_path, {'data' => data})
    end

    def exists?
      begin
        info
      rescue
        return false
      end
      true
    end

    def add_permission(principal, permission)
      @kinto_client.patch(@url_path, {'permissions' => { permission_name(permission) => [principal_name(principal)] }})
      return self
    end

    def replace_permission(principal, permission)
      @kinto_client.put(@url_path, {'permissions' => { permission_name(permission) => [principal_name(principal)] }})
      return self
    end

    def permissions
      info['permissions']
    end

    private

    def permission_name(permission)
      case permission.downcase
        when 'read'
          return 'read'
        when 'write'
          return 'write'
        when 'create'
          return 'collection:create' if self.kind_of? KintoBucket
          return 'record:create' if self.kind_of? KintoCollection
        when 'group:create'
          return 'group:create'
        else
          raise Exception 'not a valid permission'
      end
    end

    def principal_name(principal)
      case principal.downcase
        when 'authenticated'
          return 'system.Authenticated'
        when 'anonymous'
          return 'system.Everyone'
        when 'everyone'
          return 'system.Everyone'
        else
          return principal
      end
    end
  end
end