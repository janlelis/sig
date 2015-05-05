require "benchmark/ips"

require "rubype"
require "rubype/version"
require "typecheck"
require "contracts"
require "contracts/version"
require_relative "../lib/sig"

# - - -

puts "ruby version: #{RUBY_VERSION}"
puts "ruby engine: #{RUBY_ENGINE}"
puts "ruby description: #{RUBY_DESCRIPTION}"
puts "sig version: #{Sig::VERSION}"
puts "rubype version: #{Rubype::VERSION}"
puts "typecheck version: #{Typecheck::VERSION}"
puts "contracts version: #{Contracts::VERSION}"

# - - -

class PureSum
  def sum(x, y)
    x + y
  end

  def mul(x, y)
    x * y
  end
end
pure_instance = PureSum.new

# - - -

class SigSum
  sig [Numeric, Numeric], Numeric,
  def sum(x, y)
    x + y
  end

  sig [:to_i, :to_i], Numeric,
  def mul(x, y)
    x * y
  end
end
sig_instance = SigSum.new

# - - -

class RubypeSum
  def sum(x, y)
    x + y
  end
  typesig :sum, [Numeric, Numeric] => Numeric

  def mul(x, y)
    x * y
  end
  typesig :mul, [:to_i, :to_i] => Numeric
end
rubype_instance = RubypeSum.new

# - - -

class TypecheckSum
  extend Typecheck

  typecheck 'Numeric, Numeric -> Numeric',
  def sum(x, y)
    x + y
  end

  typecheck '#to_i, #to_i -> Numeric',
  def mul(x, y)
    x * y
  end
end
typecheck_instance = TypecheckSum.new

# - - -

class ContractsSum
  include Contracts

  Contract Num, Num => Num
  def sum(x, y)
    x + y
  end

  Contract RespondTo[:to_i], RespondTo[:to_i] => Num
  def mul(x, y)
    x * y
  end
end
contracts_instance = ContractsSum.new

Benchmark.ips do |x|
  x.report("pure"){ |times|
    i = 0
    while i < times
      pure_instance.sum(1, 2)
      pure_instance.mul(1, 2)
      i += 1
    end
  }

  x.report("sig"){ |times|
    i = 0
    while i < times
      sig_instance.sum(1, 2)
      sig_instance.mul(1, 2)
      i += 1
    end
  }

  x.report("rubype"){ |times|
    i = 0
    while i < times
      rubype_instance.sum(1, 2)
      rubype_instance.mul(1, 2)
      i += 1
    end
  }

  x.report("typecheck"){ |times|
    i = 0
    while i < times
      typecheck_instance.sum(1, 2)
      typecheck_instance.mul(1, 2)
      i += 1
    end
  }

  x.report("contracts"){ |times|
    i = 0
    while i < times
      contracts_instance.sum(1, 2)
      contracts_instance.mul(1, 2)
      i += 1
    end
  }

  x.compare!
end

