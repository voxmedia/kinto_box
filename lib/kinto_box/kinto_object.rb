module KintoBox
  class KintoObject
    class << self
      # Get the name of this class suitable for use in url path
      def path_name
        name.sub('KintoBox::Kinto', '').downcase + 's'
      end

      # Assign or retrieve the child class
      def child_class(value = nil)
        return @child_class if value.nil?
        @child_class = value
      end
    end

    attr_reader :id, :parent, :client

    def initialize(client: nil, id: nil, parent: nil, info: nil)
      @client = client || parent.client
      @parent = parent
      @id = id || (info ? info['data']['id'] : nil)
      @info = info
      self
    end

    # Get the path to this object in the Kinto API.
    # This method uses the name of this class and whatever @parent.url_path is
    # to create a partial url path.
    # @return [String] URL fragment
    def url_path
      path = "/#{self.class.path_name}/#{id}"
      path = parent.url_path + path unless parent.nil?
      path.gsub(%r{/+}, '/')
    end

    # Get the path to this object in the Kinto API
    # Use the name of url_path and whatever the child class has set for @parent.url_path is
    # to create a partial url path.
    # @return [String] URL fragment
    def child_path
      return unless child_class?
      "#{url_path}/#{child_class.path_name}".gsub(%r{/+}, '/')
    end

    # Check to see if this Kinto object exists
    # @return [Boolean]
    def exists?
      begin
        return false if info && info['data'] && info['data']['deleted'] == true
      rescue
        return false
      end
      true
    end

    # Get the data related to this object
    # @return [Hash] Object data
    def info
      @info ||= info_request.execute
    end

    # Delete the cached info for this object
    def reload
      @info = nil
    end

    # Delete this object
    # @return [Hash] Response
    def delete
      @info = delete_request.execute
    end

    # Update this object
    # @return [Hash] Response
    def update(data)
      @info = update_request(data).execute
    end

    # Replace all data in the object
    # @return [Hash] Response
    def replace(data)
      @info = replace_request(data).execute
    end

    # Return an object for this child
    # @param [String] Child object ID
    # @return [KintoObject] Child for ID
    def child(child_id)
      child_class.new(id: child_id, parent: self)
    end

    # Create a child object
    # @param [String] Child object ID
    # @return [KintoObject] New child
    def create_child(data)
      resp = create_child_request(data).execute
      child_class.new(info: resp, parent: self)
    end

    # Get all children
    # @param [String,Array] Filters
    # @param [String] Sort by
    # @return [Hash] All children
    def list_children(filters = nil, sort = nil)
      list_children_request(filters, sort).execute
    end

    # Get all children
    # @param [String,Array] Filters
    # @param [String] Sort by
    # @return [Hash] All children
    def delete_children(filters = nil)
      delete_children_request(filters).execute
    end

    # Count all children
    # @param [String,Array] Filters
    # @return [Integer] Count
    def count_children(filters = nil)
      count_children_request(filters).execute['Total-Records'].to_i
    end

    # Add a permission to this object
    # @param [String] Principal aka user or group name
    # @param [String] Permission name i.e. read, write, etc
    # @return [KintoObject] The current instance; for chaining
    def add_permission(principal, permission)
      @info = client.patch(url_path, 'permissions' => { permission => [principal_name(principal)] })
      self
    end

    # Replace all permissions for this object
    # @param [String] Principal aka user or group name
    # @param [String] Permission name i.e. read, write, etc
    # @return [KintoObject] The current instance; for chaining
    def replace_permission(principal, permission)
      @info = client.put(url_path, 'permissions' => { permission => [principal_name(principal)] })
      self
    end

    # Get the permissions for the current object
    # @return [Hash] Hash of permissions and assigned principals.
    def permissions
      info['permissions']
    end

    # Get a kinto request object for making an info request
    # @return [KintoRequest] Object representing this request
    def info_request
      client.create_request('GET', url_path)
    end

    # Get a kinto request object for making an update request
    # @param [Hash] Data
    # @return [KintoRequest] Object representing this request
    def update_request(data)
      client.create_request('PATCH', url_path, 'data' => data)
    end

    # Get a kinto request object for making a delete request
    # @param [Hash] Data
    # @return [KintoRequest] Object representing this request
    def replace_request(data)
      client.create_request('PUT', url_path, 'data' => data)
    end

    # Get a kinto request object for making a delete request
    # @return [KintoRequest] Object representing this request
    def delete_request
      client.create_request('DELETE', url_path)
    end

    # Get a kinto request object for making a create child request
    # @return [KintoRequest] Object representing this request
    def create_child_request(data)
      client.create_request('POST', url_w_qsp, 'data' => data)
    end

    # Get a kinto request object for making a list children request
    # @return [KintoRequest] Object representing this request
    def list_children_request(filters = nil, sort = nil)
      client.create_request('GET', url_w_qsp(filters, sort))
    end

    # Get a kinto request object for making a delete children request
    # @return [KintoRequest] Object representing this request
    def delete_children_request(filters = nil)
      client.create_request('DELETE', url_w_qsp(filters))
    end

    # Get a kinto request object for making a count children request
    # @return [KintoRequest] Object representing this request
    def count_children_request(filters = nil)
      client.create_request('HEAD', url_w_qsp(filters))
    end

    private

    # Get the class for this object's child
    # @return [KintoObject] Child class
    def child_class
      self.class.child_class
    end

    # Does this class have a child class?
    # @return [Boolean]
    def child_class?
      !(child_class.nil? || child_class.is_a?(KintoObject))
    end

    # Convert the principal name to something Kinto will like
    # @return [String] Valid Kinto principal name
    def principal_name(principal)
      case principal.downcase
      when 'authenticated'
        'system.Authenticated'
      when 'anonymous'
        'system.Everyone'
      when 'everyone'
        'system.Everyone'
      else
        principal
      end
    end

    # Build the path including querystring
    def url_w_qsp(filters = nil, sort = nil, add_child = true)
      url = child_path.nil? || !add_child ? url_path : child_path
      query_string = ''
      query_string = filters unless filters.nil?
      query_string = "#{query_string}&" unless filters.nil? || sort.nil?
      query_string = "#{query_string}_sort=#{sort}" unless sort.nil?
      query_string == '' ? url : "#{url}?#{query_string}"
    end
  end
end
