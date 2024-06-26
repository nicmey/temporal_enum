module ChronologicalEnum
  module Enum
    def enum(name = nil, values = nil, **options)
      chronological = options.delete(:_chronological)
      super(name, values, **options)

      return unless chronological

      enum_name = name || options.keys.first
      check_enum_values!(enum_name)
      add_enum_chronological_scopes(enum_name: enum_name, prefix: options[:_prefix], suffix: options[:_suffix])
    end

    private

    def add_enum_chronological_scopes(enum_name:, prefix: nil, suffix: nil)
      prefix = if prefix
                 prefix == true ? "#{enum_name}_" : "#{prefix}_"
               end

      suffix = if suffix
                 suffix == true ? "_#{enum_name}" : "_#{suffix}"
               end

      send(enum_name.to_s.pluralize).each do |key, value|
        method_name = "#{prefix}#{key}#{suffix}"

        scope "after_#{method_name}", -> { where("#{enum_name} > ?", value) }
        scope "before_#{method_name}", -> { where("#{enum_name} < ?", value) }
        scope "after_or_#{method_name}", -> { where("#{enum_name} >= ?", value) }
        scope "before_or_#{method_name}", -> { where("#{enum_name} <= ?", value) }
      end
    end

    def check_enum_values!(enum_name)
      return if send(enum_name.to_s.pluralize).values.all? { |value| value.is_a? Integer }

      raise ArgumentError, "Values for #{enum_name} must be integer to be chronological"
    end
  end
end
