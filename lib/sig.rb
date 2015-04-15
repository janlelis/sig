require_relative "sig/version"
require_relative "sig/kernel"

module Sig
  class ArgumentTypeError < ArgumentError
  end

  class ResultTypeError < RuntimeError
  end

  def self.define(object, expected_arguments, expected_result = nil, method_name)
    expected_arguments = Array(expected_arguments)
    if expected_arguments.last.is_a?(Hash)
      expected_keyword_arguments = expected_arguments.delete_at(-1)
    else
      expected_keyword_arguments = nil
    end

    method_visibility = get_method_visibility_or_raise(object, method_name)
    signature_checker = get_or_create_signature_checker(object)
    signature_checker.send :define_method, method_name do |*arguments, **keyword_arguments|
      if keyword_arguments.empty?
        ::Sig.check_arguments(expected_arguments, arguments, expected_keyword_arguments)
        result = super(*arguments)
      else
        ::Sig.check_arguments(expected_arguments, arguments, expected_keyword_arguments, keyword_arguments)
        result = super(*arguments, **keyword_arguments)
      end
      ::Sig.check_result(expected_result, result)

      result
    end
    signature_checker.send(method_visibility, method_name)

    method_name
  end

  def self.get_method_visibility_or_raise(object, method_name)
    case
    when object.private_method_defined?(method_name)
      :private
    when object.protected_method_defined?(method_name)
      :protected
    when object.public_method_defined?(method_name)
      :public
    else
      raise ArgumentError, "No method with name :#{method_name} for object #{object.inspect}"
    end
  end

  def self.get_or_create_signature_checker(object)
    unless checker = object.instance_variable_get(:@_sig)
      checker = object.instance_variable_set(:@_sig, Module.new)
      def checker.inspect() "#<Sig:#{object_id}>" end
      object.prepend(checker)
    end

    checker
  end

  def self.check_arguments(expected_arguments, arguments, expected_keyword_arguments, keyword_arguments = nil)
    errors = ""

    arguments.each_with_index{ |argument, index|
      if error = valid_or_formatted_error(expected_arguments[index], argument)
        errors << error
      end
    }

    if expected_keyword_arguments
      keyword_arguments.each{ |key, keyword_argument|
        if error = valid_or_formatted_error(expected_keyword_arguments[key], keyword_argument)
          errors << error
        end
      }
    elsif keyword_arguments &&
        error = valid_or_formatted_error(expected_arguments[arguments.size], keyword_arguments)
      errors << error
    end

    unless errors.empty?
      raise ArgumentTypeError, errors
    end
  end

  def self.check_result(expected_result, result)
    unless matches? expected_result, result
      raise ResultTypeError, format_error(expected_result, result)
    end
  end

  def self.matches?(expected, value)
    case expected
    when Array
      expected.any?{ |expected_element| matches? expected_element, value }
    when Module
      value.is_a?(expected)
    when Symbol
      value.respond_to?(expected)
    when Proc
      !!expected.call(value)
    when Regexp
      !!(expected =~ String(value))
    when Range
      expected.include?(value)
    when true
      !!value
    when false
      !value
    when nil
      true
    else
      raise ArgumentError, "Invalid signature definition: Unknown behavior #{expected}"
    end
  end

  def self.valid_or_formatted_error(expected_argument, argument)
    if !expected_argument.nil? && !matches?(expected_argument, argument)
      format_error(expected_argument, argument)
    end
  end

  def self.format_error(expected, value)
    case expected
    when Array
      expected.map{ |expected_element| format_error(expected_element, value) }*" OR"
    when Module
      "\n- Expected #{value.inspect} to be a #{expected}, but is a #{value.class}"
    when Symbol
      "\n- Expected #{value.inspect} to respond to :#{expected}"
    when Proc
      "\n- Expected #{value.inspect} to return a truthy value for proc #{expected}"
    when Regexp
      "\n- Expected stringified #{value.inspect} to match #{expected.inspect}"
    when Range
      "\n- Expected #{value.inspect} to be included in #{expected.inspect}"
    when true
      "\n- Expected #{value.inspect} to be truthy"
    when false
      "\n- Expected #{value.inspect} to be falsy"
    end
  end
end

