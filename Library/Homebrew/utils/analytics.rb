require "erb"

module Utils
  module Analytics
    class << self
      def custom_prefix_label
        "custom-prefix".freeze
      end

      def clear_os_prefix_ci
        return unless instance_variable_defined?(:@os_prefix_ci)

        remove_instance_variable(:@os_prefix_ci)
      end

      def os_prefix_ci
        @os_prefix_ci ||= begin
          os = OS_VERSION
          prefix = ", #{custom_prefix_label}" unless Homebrew.default_prefix?
          ci = ", CI" if ENV["CI"]
          "#{os}#{prefix}#{ci}"
        end
      end

      def report(type, metadata = {})
        # Never analytics...
        return
      end

      def report_event(category, action, label = os_prefix_ci, value = nil)
        report(:event,
          ec: category,
          ea: action,
          el: label,
          ev: value)
      end

      def report_build_error(exception)
        return unless exception.formula.tap
        return unless exception.formula.tap.installed?
        return if exception.formula.tap.private?

        action = exception.formula.full_name
        if (options = exception.options&.to_a&.join(" "))
          action = "#{action} #{options}".strip
        end
        report_event("BuildError", action)
      end
    end
  end
end

require "extend/os/analytics"
