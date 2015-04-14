# # #
# Get gemspec info

gemspec_file = Dir['*.gemspec'].first
gemspec = eval File.read(gemspec_file), binding, gemspec_file
info = "#{gemspec.name} | #{gemspec.version} | " \
       "#{gemspec.runtime_dependencies.size} dependencies | " \
       "#{gemspec.files.size} files"


# # #
# Gem build and install task

desc info
task :gem do
  puts info + "\n\n"
  print "  "; sh "gem build #{gemspec_file}"
  FileUtils.mkdir_p 'pkg'
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", 'pkg'
  puts; sh %{gem install --no-document pkg/#{gemspec.name}-#{gemspec.version}.gem}
end


# # #
# Start an IRB session with the gem loaded

desc "#{gemspec.name} | IRB"
task :irb do
  sh "irb -I ./lib -r #{gemspec.name.gsub '-','/'}"
end


# # #
# Benchmark: Take with a grain of salt

desc "Compare with contracts and rubype"
task :benchmark do
  require "benchmark/ips"
  require "rubype"
  require "rubype/version"
  require "contracts"
  require "contracts/version"
  require_relative "lib/sig"

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
  puts "ruby version: #{RUBY_VERSION}"

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
  puts "sig version: #{Sig::VERSION}"

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
  puts "rubype version: #{Rubype::VERSION}"

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
  puts "contracts version: #{Contracts::VERSION}"

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
end


# # #
# Specs

desc "Run specs"
task :spec do
  ruby "spec/sig_spec.rb"
end
task default: :spec
