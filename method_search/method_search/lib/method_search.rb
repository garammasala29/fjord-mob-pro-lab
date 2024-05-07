# frozen_string_literal: true

require_relative "method_search/version"

module MethodSearch
  class Error < StandardError; end
  # Your code goes here...
  def self.search(method_name)
    ObjectSpace.each_object(Class).select do |klass|
      if klass.method_defined?(method_name)
        klass.instance_method(method_name).owner
      end
    end.reject { _1.singleton_class? }
  end
end
