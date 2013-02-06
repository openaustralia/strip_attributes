require "active_model"

module ActiveModel::Validations::HelperMethods
  # Strips whitespace from model fields and converts blank values to nil.
  def strip_attributes(options = nil)
    before_validation do |record|
      allow_empty = options.delete(:allow_empty) if options

      attribute_names = StripAttributes.narrow(record.attribute_names, options)
      attribute_names.each do |attribute_name|
        value = record[attribute_name]
        if value.respond_to?(:strip)
          record[attribute_name] = (value.blank? && !allow_empty) ? nil : value.strip
        end
      end
    end
  end

  # <b>DEPRECATED:</b> Please use <tt>strip_attributes</tt> (non-bang method)
  # instead.
  def strip_attributes!(options = nil)
    warn "[DEPRECATION] `strip_attributes!` is deprecated.  Please use `strip_attributes` (non-bang method) instead."
    strip_attributes(options)
  end
end

module StripAttributes
  # Necessary because Rails has removed the narrowing of attributes using :only
  # and :except on Base#attributes
  def self.narrow(attribute_names, options)
    if options.nil? || options.empty?
      attribute_names
    else
      attribute_names = attribute_names.collect { |attribute| attribute.to_s }
      if except = options[:except]
        except = Array(except).collect { |attribute| attribute.to_s }
        attribute_names - except
      elsif only = options[:only]
        only = Array(only).collect { |attribute| attribute.to_s }
        attribute_names & only
      else
        raise ArgumentError, "Options does not specify :except or :only (#{options.keys.inspect})"
      end
    end
  end
end
