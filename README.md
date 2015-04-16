# `sig`: Optional Type Assertions for Ruby methods. [![[version]](https://badge.fury.io/rb/sig.svg)](http://badge.fury.io/rb/sig)  [![[travis]](https://travis-ci.org/janlelis/sig.png)](https://travis-ci.org/janlelis/sig)

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

The rubype gem achieves similar things like sig (and inspired the creation of sig). It offers a different syntax and differs in feature & implementation details, so in the end, it is a matter of taste, which gem you prefer. The performance impact is quite similar (sig version 1.0 vs rubype 0.2.5), run `rake benchmark` for details.

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

```
ruby version: 2.2.2
sig version: 1.0.1
rubype version: 0.2.5
contracts version: 0.8
Calculating -------------------------------------
                pure    59.389k i/100ms
                 sig     9.386k i/100ms
              rubype     8.343k i/100ms
           contracts     5.011k i/100ms
-------------------------------------------------
                pure      4.660M (± 0.6%) i/s -     23.340M
                 sig    136.535k (± 0.7%) i/s -    685.178k
              rubype    112.444k (± 0.4%) i/s -    567.324k
           contracts     60.699k (± 0.4%) i/s -    305.671k

Comparison:
                pure:  4660112.0 i/s
                 sig:   136535.0 i/s - 34.13x slower
              rubype:   112443.6 i/s - 41.44x slower
           contracts:    60698.9 i/s - 76.77x slower
```

There is still a lot room for performance improvements. Feel free to suggest some faster implementation to do the type checks (even if it is crazy and not clean, as long it does not add too much "magic", a.k.a does not make debugging harder).

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
