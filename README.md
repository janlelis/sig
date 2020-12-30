# `sig`: Optional Type Assertions for Ruby methods. [![[version]](https://badge.fury.io/rb/sig.svg)](http://badge.fury.io/rb/sig)  [![[ci]](https://github.com/janlelis/sig/workflows/Test/badge.svg)](https://github.com/janlelis/sig/actions?query=workflow%3ATest)

This gem adds the `sig` method that allows you to add signatures to Ruby methods. When you call the method, it will verify that the method's arguments/result fit to the previously defined behavior:

```ruby
# On main object
sig [:to_i, :to_i], Integer,
def sum(a, b)
  a.to_i + b.to_i
end

sum(42, false)
# Sig::ArgumentTypeError:
# - Expected false to respond to :to_i

# In modules
class A
  sig [Numeric, Numeric], Numeric,
  def mul(a, b)
    a * b
  end
end

A.new.mul(4,"3")
# Sig::ArgumentTypeError:
# - Expected "3" to be a Numeric, but is a String


# Explicitely define signature for singleton_class
class B
  sig_self [:reverse],
  def self.rev(object)
    object.reverse
  end
end

B.rev 42
# Sig::ArgumentTypeError:
# - Expected 42 to respond to :reverse
```

The first argument is an array that defines the behavior of the method arguments, and the second one the behavior of the method result. Don't forget the trailing comma, because the method definition needs to be the last argument to the `sig` method.

## Features & Design Goals
* Provide an intuitive way to define signatures
* Only do argument/result type checks, nothing else
* Use Ruby's inheritance chain, don't redefine methods
* Encourage duck typing
* Should work with keyword arguments
* Only target Ruby 2.1+

### This is not static typing. Ruby is a dynamic language:

Nevertheless, nothing is wrong with ensuring specific behaviour of method arguments when you need it.

### Is this better than rubype?

The rubype gem achieves similar things like sig (and inspired the creation of sig). It offers a different syntax and differs in feature & implementation details, so in the end, it is a matter of taste, which gem you prefer.

## Setup

Add to your `Gemfile`:

```ruby
gem 'sig'
```

## Usage

See example at top for basic usage.

### Supported Behavior Types

You can use the following behavior types in the signature definition:

Type    | Meaning
------- | -------
Symbol  | Argument must respond to a method with this name
Module  | Argument must be of this module
Array   | Argument can be of any type found in the array
true    | Argument must be truthy
false   | Argument must be falsy
nil     | Wildcard for any argument

### Example Signatures

```ruby
sig [:to_i], Numeric,              # takes any object that responds to :to_i as argument, numeric result
sig [Numeric], String,             # one numeric argument, string result
sig [Numeric, Numeric], String,    # two numeric arguments, string result
sig [:to_s, :to_s],                # two arguments that support :to_s, don't care about result
sig nil, String,                   # don't care about arguments, as long result is string
sig {keyword: Integer}             # keyword argument must be an intieger
sig [:to_f, {keyword: String}],    # mixing positional and keyword arguments is possible
sig [[Numeric, NilClass]], Float   # one argument that must nil or numeric, result must be float
sig [Numeric, nil,  Numeric],      # first and third argument must be numeric, don't care about type of second
```

See source(https://github.com/janlelis/sig/blob/master/lib/sig.rb) or specs(https://github.com/janlelis/sig/blob/master/spec/sig_spec.rb) for more features.

## Benchmark (Take with a Grain of Salt)

You can run `rake  benchmark` to run [it](https://github.com/janlelis/sig/blob/v1.0.1/Rakefile#L33-L148) on your machine.

There is still a lot room for performance improvements. Feel free to suggest some faster implementation to do the type checks (even if it is crazy and not clean, as long it does not add too much "magic", a.k.a does not make debugging harder).

Note: Starting with 0.3.0, rubype uses a C extension, which makes it much faster. The benchmark is still run with rubype 0.2.5, because 0.3.x currently does not work on jruby & rbx.

### MRI

```
ruby version: 2.2.2
ruby engine: ruby
ruby description: ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-linux]
sig version: 1.0.1
rubype version: 0.2.5
contracts version: 0.9
Calculating -------------------------------------
                pure   107.628k i/100ms
                 sig    14.425k i/100ms
              rubype    12.715k i/100ms
           contracts     7.688k i/100ms
-------------------------------------------------
                pure      6.856M (± 0.9%) i/s -     34.333M
                 sig    192.440k (± 1.5%) i/s -    966.475k
              rubype    164.811k (± 0.8%) i/s -    826.475k
           contracts     90.089k (± 0.7%) i/s -    453.592k

Comparison:
                pure:  6855615.3 i/s
                 sig:   192439.7 i/s - 35.62x slower
              rubype:   164810.5 i/s - 41.60x slower
           contracts:    90088.6 i/s - 76.10x slower
```

### JRuby 9000

```
ruby version: 2.2.2
ruby engine: jruby
ruby description: jruby 9.0.0.0-SNAPSHOT (2.2.2) 2015-05-04 6055b79 Java HotSpot(TM) 64-Bit Server VM 24.80-b11 on 1.7.0_80-b15 +indy +jit [linux-amd64]
sig version: 1.0.1
rubype version: 0.2.5
contracts version: 0.9
Calculating -------------------------------------
                pure    70.898k i/100ms
                 sig     5.308k i/100ms
              rubype     3.152k i/100ms
           contracts   279.000  i/100ms
-------------------------------------------------
                pure      8.848M (±13.7%) i/s -     42.539M
                 sig    178.169k (±10.3%) i/s -    881.128k
              rubype    119.689k (±26.5%) i/s -    444.432k
           contracts     56.780k (±16.8%) i/s -    265.887k

Comparison:
                pure:  8848039.4 i/s
                 sig:   178168.8 i/s - 49.66x slower
              rubype:   119689.0 i/s - 73.93x slower
           contracts:    56780.4 i/s - 155.83x slower
```

### RBX 2.5.3

```
ruby version: 2.1.0
ruby engine: rbx
ruby description: rubinius 2.5.3.c25 (2.1.0 fbb3f1e4 2015-05-02 3.4 JI) [x86_64-linux-gnu]
sig version: 1.0.1
rubype version: 0.2.5
contracts version: 0.9
Calculating -------------------------------------
                pure   114.964k i/100ms
                 sig     9.654k i/100ms
              rubype     3.775k i/100ms
           contracts     3.964k i/100ms
-------------------------------------------------
                pure     23.585M (± 3.3%) i/s -    117.263M
                 sig    134.304k (± 3.1%) i/s -    675.780k
              rubype     56.042k (± 1.7%) i/s -    283.125k
           contracts     69.820k (± 1.8%) i/s -    348.832k

Comparison:
                pure: 23585373.7 i/s
                 sig:   134303.7 i/s - 175.61x slower
           contracts:    69819.9 i/s - 337.80x slower
              rubype:    56042.1 i/s - 420.85x slower
```

## Deactivate All Signature Checking

```ruby
require 'sig/none' # instead of require 'sig'
```

## Alternatives for Type Checking and More

- https://github.com/gogotanaka/Rubype
- https://github.com/egonSchiele/contracts.ruby
- https://github.com/plum-umd/rtc

## MIT License

Copyright (C) 2015 Jan Lelis <http://janlelis.com>. Released under the MIT license.
