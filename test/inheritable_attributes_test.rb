require 'rubygems'
require 'test/unit'
require 'active_support/core_ext/blank'
require 'active_support/core_ext/module/aliasing'
require 'inheritable_attributes'

class Thing
  include InheritableAttributes

  attr_reader :foo
  
  inherit_attribute :foo, :from=>:parent
  
  def initialize(parent, foo=nil)
    @parent = parent
    @foo = foo
  end
  
  def read_attribute(attribute)
    instance_variable_get("@#{attribute}")
  end
  
  def parent
    @parent
  end
end

class Thing2 < Thing
  attr_reader :bar, :baz
  inherit_attributes [:bar, :baz], :from=>:parent
  
  def initialize(parent, foo=nil, bar=nil, baz=nil)
    super(parent, foo)
    @bar = bar
    @baz = baz
  end
end

class Thing3 < Thing
  attr_reader :bar, :baz
  inherit_attribute :bar, :from=>:parent, :as => :foo
  inherit_attribute :baz, :from=>:parent
  
  def initialize(parent, foo=nil, bar=nil, baz=nil)
    super(parent, foo)
    @bar = bar
    @baz = baz
  end
end

class InheritableAttributesTest < Test::Unit::TestCase
  def test_argument_error
    assert_raise(ArgumentError) do
      eval <<-EOF
        class BadThing < Thing
          inherit_attribute :bar
        end
      EOF
    end
  rescue
    
  end
  def test_one_level
    thing = Thing.new(nil, nil)
    assert_equal(nil, thing.foo)
    
    thing = Thing.new(nil, "")
    assert_equal("", thing.foo)
    
    thing = Thing.new(nil, :foo)
    assert_equal(:foo, thing.foo)
  end
  
  def test_two_levels
    nil_parent = Thing.new(nil, nil)
    parent = Thing.new(nil, :foo)
    
    # child's foo is nil
    thing = Thing.new(nil_parent, nil)
    assert_equal(nil, thing.foo)

    thing = Thing.new(parent, nil)
    assert_equal(:foo, thing.foo)

    # child's foo is ""
    thing = Thing.new(nil_parent, "")
    assert_equal(nil, thing.foo)

    thing = Thing.new(parent, "")
    assert_equal(:foo, thing.foo)

    # child's foo is :bar
    thing = Thing.new(nil_parent, :bar)
    assert_equal(:bar, thing.foo)

    thing = Thing.new(parent, :bar)
    assert_equal(:bar, thing.foo)
  end
  
  def test_multi_vars
    nil_parent = Thing2.new(nil)
    parent = Thing2.new(nil, :foo_parent, :bar_parent, :baz_parent)

    thing = Thing2.new(parent)
    assert_equal(:foo_parent, thing.foo)
    assert_equal(:bar_parent, thing.bar)
    assert_equal(:baz_parent, thing.baz)

    thing = Thing2.new(nil_parent, :foo, :bar, :baz)
    assert_equal(:foo, thing.foo)
    assert_equal(:bar, thing.bar)
    assert_equal(:baz, thing.baz)
  end
  
  def test_as
    parent = Thing2.new(nil, :foo_parent, :bar_parent, :baz_parent)

    thing = Thing3.new(parent)
    assert_equal(:foo_parent, thing.foo)
    assert_equal(:foo_parent, thing.bar)
    assert_equal(:baz_parent, thing.baz)
  end
end
