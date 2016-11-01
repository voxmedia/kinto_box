module KintoBox
  class KintoObject

    attr_accessor :id
    attr_reader :url_path

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
      @kinto_client.patch(@url_path, {'permissions' => { permission => [principal_name(principal)] }})
      self
    end

    def replace_permission(principal, permission)
      @kinto_client.put(@url_path, {'permissions' => { permission => [principal_name(principal)] }})
      self
    end

    def permissions
      info['permissions']
    end

    private

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

    def url_w_qsp(filters = nil, sort = nil)
      url = @child_path.nil? ? @url_path : @url_path + @child_path
      query_string = '?'
      query_string += filters unless filters.nil?
      query_string += '&' unless filters.nil? || sort.nil?
      query_string += "_sort=#{sort}" unless sort.nil?
      query_string == '?' ? "#{url}" : "#{url}#{query_string}"
    end
  end
end