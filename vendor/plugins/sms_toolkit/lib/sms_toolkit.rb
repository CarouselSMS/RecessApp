# Mixins
module SmsToolkit
  
  # Main toolkit class
  class PhoneNumbers

    # Normalizes the US phone number.
    # - Converts the number in the format "+1nnnnnnnnnn" or "001nnnnnnnnnn" to 10-digits.
    # - Leaves short-codes intact (e.g. "nnnnnn")
    def self.normalize(number)
      return number if number.blank?
      
      # Cleanup
      number = number.strip.gsub(/[\-\s\(\)]/, '')
      
      number.gsub(/^\+?1?(\d{10})$/, '\1').gsub(/^001?(\d+)$/, '\1')
    end

    # Formats the 10-digit number or the short-code as the US number.
    def self.format(number)
      return number if number.blank?
      
      if /^\s*\+?[\d\-\s\(\)]+\s*$/ =~ number
        number = normalize(number)
        
        if /^\d{10}$/ =~ number
          format_10_digit_number(number)
        elsif /^\d{1,9}$/ =~ number
          format_short_code(number)
        else
          number
        end
      else
        number
      end
    end

    private

    # Formats 10-digit number
    def self.format_10_digit_number(number)
      "(#{number[0, 3]}) #{number[3, 3]}-#{number[6, 4]}"
    end

    # Formats short-code
    def self.format_short_code(number)
      number
    end

  end

  # Helper mix-in
  module HelperMixin
  
    # Returns the formatted phone number
    def formatted_phone_number(number)
      PhoneNumbers.format(number)
    end

  end
  
end
