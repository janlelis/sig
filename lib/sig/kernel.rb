module Kernel
  private

  # Defines a method signature for a method on this object:
  #
  #   sig [:to_i, :to_i], Integer,
  #   def sum(a, b)
  #     a.to_i + b.to_i
  #   end
  #
  def sig(expected_arguments, expected_result = nil, method_name)
    if is_a?(Module)
      Sig.define(self, expected_arguments, expected_result, method_name)
    else
      sig_self(expected_arguments, expected_result, method_name)
    end
  end

  # Defines a method signature for a method on this object's singleton class
  #
  #   sig_self [:to_i, :to_i], Integer,
  #   def self.sum(a, b)
  #     a.to_i + b.to_i
  #   end
  #
  def sig_self(expected_arguments, expected_result = nil, method_name)
    Sig.define(singleton_class, expected_arguments, expected_result, method_name)
  end
end
