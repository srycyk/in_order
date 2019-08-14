
require 'test_helper'

describe InOrder::Aux::Keys do
  OWNER_PARAMS = { owner_type: 'Type', owner_id: 0 }

  def keys(*args)
    InOrder::Aux::Keys.new(*args)
  end

  def owner
    Owner.new name: 'your price'
  end

  it "calls with extras" do
    keys = keys(owner, 'Scope')

    expected = { extra: 'Extra', owner_type: 'Owner', owner_id: nil, scope: 'Scope' }

    assert_equal expected, keys.(extra: 'Extra')
  end

  it 'is equal' do
    assert_equal keys('Owner', 'Scope'), keys('Owner', 'Scope')
  end

  it 'is not equal' do
    refute_equal keys('Owner', 'Scope'), keys('Owner', '')

    refute_equal keys('Owner', 'Scope'), keys('', 'Scope')
  end

  it 'is valid' do
    assert keys('').valid?
  end

  it 'is invalid' do
    refute keys.valid?
  end

  it 'accepts hash as owner' do
    assert_equal OWNER_PARAMS, keys(owner: OWNER_PARAMS).owner
  end

  it 'accepts array as owner' do
    assert_equal ['Type', 0], keys(['Type', 0]).owner
  end

  it 'returns key values with to_params' do
    expected = OWNER_PARAMS.merge(scope: 'Scope')

    assert expected, keys(OWNER_PARAMS, 'Scope').to_params
  end
end

