require 'json_validator'
require 'json_with_indifferent_access'

# Note: looks like we're deviating from Rails expected conventions. Maybe
# reimplement in light of:
#   https://nvisium.com/blog/2015/06/22/using-rails-5-attributes-api-today-in/
module NodeProperties
  def self.included(base)
    @base = base

    base.class_eval do
      # Node properties:
      # * Serialized as JSON
      # * The smart setter set_property(key, value) takes care of duplications, etc.
      serialize :properties, JSONWithIndifferentAccess

      validates :raw_properties, json: { message: 'contains invalid JSON' }
    end
  end

  SERVICE_KEYS = %i[port protocol state product reason name version]

  # -------------------------------------------- Individual property management
  # Sets a property, storing value as Array when needed
  # and taking care of duplications
  def set_property(key, value)
    if key == :services # let's get defensive
      msg = "don't use set_property for :services, use set_service instead"
      raise ArgumentError, msg
    end

    current_value = self.properties[key]

    # Even though we're serializing JSONWithIndifferentAccess, and the
    # properties can be returned using String or Symbol keys, the
    # :value_is_there variable defined below is depending on Array's #include?
    # and this method wouldn't match two hashes unless they're both
    # #with_indifferent_access
    value = value.with_indifferent_access if value.is_a?(Hash)

    value_is_there = (current_value == value) || (current_value.is_a?(Array) && current_value.include?(value))
    return current_value if value.blank? || value_is_there

    if current_value.blank?
      self.properties[key] = value
    else
      self.properties[key] = [current_value, value].flatten.uniq
    end

    self.properties[key] = self.properties[key].first if self.properties[key].size == 1

    return self.properties[key]
  end

  def has_any_property?
    self.properties.keys.any?{ |p| self.properties[p].present? }
  end

  # -------------------------------------------- Individual property management
  def set_service(data)
    port     = data.fetch(:port)
    protocol = data.fetch(:protocol)

    core  = data.slice(*SERVICE_KEYS)
    extra = data.except(*SERVICE_KEYS)

    self.properties[:services] ||= []
    this_service = self.properties[:services].find do |service|
      service[:port] == port && service[:protocol] == protocol
    end

    if this_service.nil?
      self.properties[:services].push(core)
    else
      # the variable 'this_service' is a reference, so updating it like this
      # will update the entry in original properties[:services] array
      this_service.merge!(core)
    end

    # TODO - add 'service_extras'
  end


  # -------------------------------------- :raw_properties accessors for the UI
  def raw_properties
    if self.has_any_property?
      JSON.pretty_generate(self.properties.to_hash)
    elsif @raw_properties
      @raw_properties
    else
      "{\n}"
    end
  end

  # We do this as a two-step operation:
  #   - First we try to detect JSON errors. If none are found, we set the
  #   Node's properties.
  #   - If there is an error, we keep the malformed value (to give the user a
  #   chance of fixing it), but don't assign the Node's properties.
  def raw_properties=(value)
    @raw_properties = JSON::parse(value)
    self.properties = @raw_properties
  rescue JSON::ParserError => exception
    @raw_properties = value
  end
end
