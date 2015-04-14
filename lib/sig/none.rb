# require "sig/none" instead of "sig" to get fake methods that do nothing

require_relative '../sig'

module Kernel
  private

  def sig(_, _ = nil, method_name)
    method_name
  end
  #
  def sig_self(_, _ = nil, method_name)
    method_name
  end
end
