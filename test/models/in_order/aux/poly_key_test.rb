
require 'test_helper'

describe InOrder::Aux::PolyKey do
  TYPE = 'Ahead'
  ID = '0'

  ARGUMENTS = [ [TYPE, ID], "#{TYPE} #{ID}", type: TYPE, id: ID ]

  DELIMENTERS = '-,:/^\|'

  def poly_key(*args)
    InOrder::Aux::PolyKey.new(*args)
  end

  def default_key
    poly_key(ARGUMENTS.first)
  end

  def assert_key_valued(key, type=TYPE, id=ID)
    assert_equal type, key.type

    # For deprecation nil == nil
    if id
      assert_equal id, key.id
    else
      assert_nil key.id
    end
  end

  it "is assigned from model" do
    model = Subject.create(name: 'xxx')

    key = poly_key model

    assert_key_valued key, model.class.name, model.to_param
  end

  it "is initialised with two flat args" do
    key = poly_key TYPE, ID

    assert_key_valued key
  end

  it "is assigned with just a type" do
    key = poly_key TYPE

    assert_key_valued key, TYPE, nil
  end

  it "is reassigned with just an id" do
    key = poly_key TYPE

    assert_key_valued key.set(id: 999), TYPE, 999
  end

  it 'accepts nil as constructor arg' do
    assert poly_key nil
  end

  it 'shows string' do
    assert_equal [TYPE, '-', ID].join, default_key.to_s
  end

  it 'shows array' do
    assert_equal [TYPE, ID], default_key.to_a
  end

  it 'shows named attributes hash' do
    expected = { my_type: TYPE, my_id: ID }

    assert_equal expected, poly_key(ARGUMENTS.sample, name: :my).to_h
  end

  it 'shows bare attributes hash' do
    expected = { type: TYPE, id: ID }

    assert_equal expected, default_key.to_bare_params
  end

  it 'shows params by default name' do
    expected = { ahead: { type: TYPE, id: ID } }

    assert_equal expected, default_key.to_params_by_name
  end

  it 'shows params by given name' do
    expected = { given: { type: TYPE, id: ID } }

    assert_equal expected, default_key.to_params_by_name(:given)
  end

  it 'uses default name' do
    key = poly_key(nil, default_name: 'a')

    assert_equal :a_b, key.send(:full_name, 'b')
  end

  it 'validates' do
    refute default_key.set(nil).valid?
    refute default_key.set('').valid?

    refute default_key.set(id: nil).valid?
    refute default_key.set(id: ' ').valid?
  end

  ARGUMENTS.each do |args|
    it "is assigned from args: #{args.inspect}" do
      key = poly_key args

      assert_key_valued key
    end
  end

  DELIMENTERS.each_char do |delim|
    it "is assigned from string with delim #{delim} (#{delim.ord})"  do
      key_string = [ TYPE, delim, ID].join

      key = poly_key key_string

      assert_key_valued key
    end
  end
end

