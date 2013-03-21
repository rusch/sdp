require_relative 'sdp/version'
require_relative 'sdp/description'
require_relative 'sdp/parser'
require_relative 'sdp/parse_error'


# The only use for this class is the +#parse+ method, which is in this
# base class solely for convenience.  Other than this method, this
# base class doesn't really do anything.
class SDP

  # Parses the given text in to an +SDP::Description+ object.
  #
  # @param [String] sdp_text The text from an SDP description.
  # @return [SDP::Description] The object that represents the description
  #   that was parsed.
  # @raise [SDP::ParseError] If parsing fails, raise an SDP::ParseError instead
  #   of a Parslet exception that might confuse SDP users.
  def self.parse sdp_text
    begin
      sdp_hash = SDP::Parser.new.parse sdp_text
    rescue Parslet::UnconsumedInput => ex
      raise SDP::ParseError, ex
    end

    SDP::Description.new(remove_parslet(sdp_hash))
  end

  private

  # The Parser parses values as Parslet::Slice objects.  This converts those
  # values to Strings and Integers.
  #
  # @param [Hash] sdp_hash The parsed Hash.
  # @return [Hash] The converted Hash.
  def self.remove_parslet(sdp_hash)
    sdp_hash.inject({}) do |result, (k, v)|
      case v.class.to_s
      when 'Parslet::Slice'
        val = v.str
        result[k] = Integer(val) rescue val
      when 'Hash'
        result[k] = self.remove_parslet(v)
      when 'Array'
        result[k] = v.collect { |_| self.remove_parslet(_) }
      else
        result[k] = v
      end
      result
    end
  end
end
