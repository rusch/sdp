require_relative 'runtime_error'

class SDP
  class MediaDescription
    ALLOWED_TYPES = [
      'video', 'audio', 'text', 'application', 'message', 'control', 'data'
    ]

    FIELDS = [
      :media,
      :transport_port,
      :transport_protocol,
      :transport_format,
      :information,
      :bandwidths,
      :connection_network_type,
      :connection_address_type,
      :connection_address,
      :attributes,
    ]

    FIELDS.each do |field|
      attr_accessor field
    end

    def initialize(hash = {})
      FIELDS.each do |field|
        send("#{field}=", hash[field]) if hash.has_key?(field)
      end

      # Deprecate these?
      [ :port, :protocol, :format ].each do |field|
        send("transport_#{field}=", hash[field]) if hash.has_key?(field)
      end
    end

    def media=(value)
      unless ALLOWED_TYPES.include?(value)
        raise SDP::RuntimeError,
          "Media type #{value.inspect} not one of #{ALLOWED_TYPES.join(', ')}"
      end

      @media = value
    end

    def to_s
      session = ("m=%s %s %s %s\r\n" %
        [ media, transport_port, transport_protocol, transport_format ])

      if information
        session << ("i=%s\r\n" % [ information ])
      end

      if connection_network_type
        session << ("c=%s %s %s\r\n" %
          [ connection_network_type, connection_address_type, connection_address ])
      end

      if bandwidths
        bandwidths.each do |b|
          session << ("b=%s:%s\r\n" % [ b[:bandwidth_type], b[:bandwidth] ])
        end
      end

      if attributes
        attributes.each do |a|
          session << "a=#{a[:attribute]}"
          session << ":#{a[:value]}" if a[:value]
          session << "\r\n"
        end
      end

      session
    end

    # Checks to see if it has connection fields set.
    #
    # @return [Boolean]
    def has_connection_fields?
      !!(connection_network_type && connection_address_type &&
        connection_address)
    end
  end
end
