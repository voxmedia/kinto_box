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

    def info_request
      KintoRequest.new('GET', @url_path)
    end

    def update_request(data)
      KintoRequest.new('PATCH', @url_path, {'data' => data})
    end

    def delete_request
      KintoRequest.new('DELETE', @url_path)
    end

    def create_child_request(data)
      KintoRequest.new('POST', url_w_qsp, { 'data' => data})
    end

    def list_children_request(filters = nil, sort = nil)
      KintoRequest.new('GET', url_w_qsp(filters, sort))
    end

    def delete_children_request(filters = nil)
      KintoRequest.new('DELETE', url_w_qsp(filters))
    end

    def count_children_request(filters = nil)
      KintoRequest.new('HEAD',  url_w_qsp(filters))
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

    def url_w_qsp(filters = nil, sort = nil, add_child = true)
      url = @child_path.nil? || !add_child ? @url_path : "#{@url_path}#{@child_path}"
      query_string = ''
      query_string = filters unless filters.nil?
      query_string = "#{query_string}&" unless filters.nil? || sort.nil?
      query_string = "#{query_string}_sort=#{sort}" unless sort.nil?
      query_string == '' ? url : "#{url}?#{query_string}"
    end
  end
end