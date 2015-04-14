require_relative "../lib/sig"
require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new


describe Sig do
  let(:instance){ klass.new }
  let(:klass){
    Class.new do
      def my_method(object)
      end

      def sum(a, b)
        a + b
      end

      def key(arg, word: 42)
      end

      def priv
      end
      private :priv

      def prot
      end
      protected :prot

      def self.mul(a, b)
        a * b
      end
    end
  }


  describe "Kernel#sig" do
    describe "self is no Module" do
      it "will call Sig.define(...) for self's singleton_class" do
        sig [String],
        def bla(argument)
        end

        assert_raises Sig::ArgumentTypeError do
          bla 42
        end
      end
    end

    describe "self if a Module" do
      it "will call Sig.define(...) for self" do
        class Klass
          sig [String],
          def bla(argument)
          end
        end

        assert_raises Sig::ArgumentTypeError do
          Klass.new.bla 42
        end
      end
    end
  end

  describe "sig_self" do
    it "will always call Sig.define(...) on self's singleton_class" do
      class Klass
        sig_self [String],
        def self.blubb(argument)
        end
      end

      assert_raises Sig::ArgumentTypeError do
        Klass.blubb 42
      end
    end
  end

  describe "Types" do
    describe "Module" do
      it "will do nothing if value is kind of module" do
        Sig.define klass, [Numeric], :my_method
        instance.my_method(42)
        assert true
      end

      it "will raise if value is not kind of module" do
        Sig.define klass, [Array], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method(42)
        end
      end
    end

    describe "Symbol" do
      it "will do nothing if value is kind of module" do
        Sig.define klass, [:to_i], :my_method
        instance.my_method("string")
        assert true
      end

      it "will raise if value does not respond to method named by the symbol" do
        Sig.define klass, [:to_i], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method(true)
        end
      end
    end

    describe "Proc" do
      it "will do nothing if value does return a falsy result after being processed by the proc" do
        Sig.define klass, [->(e){ e.odd? }], :my_method
        instance.my_method(43)
        assert true
      end

      it "will raise if value does return a truthy result after being processed by the proc" do
        Sig.define klass, [->(e){ e.odd? }], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method(42)
        end
      end
    end

    describe "Regexpg" do
      it "will do nothing if stringified value does match" do
        Sig.define klass, [/bla/], :my_method
        instance.my_method("bla")
        assert true
      end

      it "will raise if stringified value does not match" do
        Sig.define klass, [/bla/], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method("blubb")
        end
      end
    end

    describe "Range" do
      it "will do nothing if included in range" do
        Sig.define klass, [1...100], :my_method
        instance.my_method(42)
        assert true
      end

      it "will raise if not included in range" do
        Sig.define klass, [1...100], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method("blubb")
        end
      end
    end

    describe "true" do
      it "will do nothing if value is truthy" do
        Sig.define klass, [true], :my_method
        instance.my_method(42)
        assert true
      end

      it "will raise if value is not truthy" do
        Sig.define klass, [true], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method(nil)
        end
      end
    end

    describe "false" do
      it "will do nothing if value is falsy" do
        Sig.define klass, [false], :my_method
        instance.my_method(nil)
        assert true
      end

      it "will raise if value is not falsy" do
        Sig.define klass, [false], :my_method
        assert_raises Sig::ArgumentTypeError do
          instance.my_method(42)
        end
      end
    end

    describe "nil" do
      it "will never raise" do
        Sig.define klass, [nil], :my_method
        instance.my_method(42)
        assert true
      end
    end
  end

  describe "Formats" do
    it "checks both parameters" do
      Sig.define klass, [Integer, Float], :sum
      assert_raises Sig::ArgumentTypeError do
        instance.sum(42, 42)
      end
    end

    it "will check the result if another parameter is given to sig" do
      Sig.define klass, [Integer, Integer], Float, :sum
      assert_raises Sig::ResultTypeError do
        instance.sum(42, 42)
      end
    end

    it "is possible to only check for result type" do
      Sig.define klass, nil, Float, :sum
      assert_raises Sig::ResultTypeError do
        instance.sum(42, 42)
      end
    end

    it "is possible to check for one of multiple given types" do
      Sig.define klass, [[Numeric, String]], :my_method
      instance.my_method(42)
      assert true
    end

    describe "Keyword Arguments" do
      it "works" do
        Sig.define klass, {word: String}, :key
        assert_raises Sig::ArgumentTypeError do
          instance.key(nil, word: 42)
        end
      end

      it "works with mixed positionial and keyword parameters" do
        Sig.define klass, [Numeric, {word: String}], :key
        assert_raises Sig::ArgumentTypeError do
          instance.key(42, word: 43)
        end
      end

      it "works with mixed positionial and keyword parameters 2" do
        Sig.define klass, [Numeric, {word: String}], :key
        assert_raises Sig::ArgumentTypeError do
          instance.key("42", word: "43")
        end
      end
    end
  end

  describe "Implementation Details" do
    it "can be used on instance level" do
      Sig.define klass, [Numeric], :sum
      assert_raises Sig::ArgumentTypeError do
        instance.sum("str", "ing")
      end
    end

    it "can be used on class level" do
      Sig.define klass.singleton_class, [Numeric], :mul
      assert_raises Sig::ArgumentTypeError do
        klass.mul("str", "ing")
      end
    end

    it "defines an anomynous signature checker module" do
      Sig.define klass, [Numeric], :sum
      assert_equal Module, klass.instance_variable_get(:@_sig).class
    end

    it "uses the same signature module for multiple signatures" do
      Sig.define klass, [Numeric], :sum
      Sig.define klass, [Numeric], :my_method
      assert_equal 2, klass.instance_variable_get(:@_sig).instance_methods.size
    end

    it "does not define signature modules if no signature is used in the class" do
      assert_equal nil, klass.instance_variable_get(:@_sig)
    end

    it "respects restricted visibility of private methods" do
      Sig.define klass, [String], :priv
      assert_raises NoMethodError do
        instance.priv
      end
    end

    it "respects restricted visibility of protected methods" do
      Sig.define klass, [String], :prot
      assert_raises NoMethodError do
        instance.prot
      end
    end
  end

  describe "Wrong Usage" do
    it "will raise an ArgumentError if trying to define a signature for an unknown method" do
      assert_raises ArgumentError do
        Sig.define klass, [String], :unknown
      end
    end
    it "will raise an ArgumentError if unknown signature types are used" do
      assert_raises ArgumentError do
        Sig.define klass, [Object.new], :my_method
        klass.new.my_method(42)
      end
    end
  end
end

