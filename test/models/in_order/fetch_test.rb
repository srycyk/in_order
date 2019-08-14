
require 'test_helper'

describe InOrder::Fetch do
  include SetupElements

  def new_owner
    Owner.create(name: 'A new owner')
  end

  def owner_no_scope_keys
    keys scope: nil 
  end
  def scope_keys
    keys owner: nil
  end
  def new_owner_keys
    keys owner: new_owner
  end
  def new_owner_no_scope_keys
    keys owner: new_owner, scope: nil
  end

  def keys_list
    @keys_list ||= [ keys, owner_no_scope_keys, scope_keys,
                     new_owner_keys, new_owner_no_scope_keys ]
  end

  def elements_list
    keys_list.map.with_index do |keys, index|
      subject_list = subjects[0, index + 1]

      create_elements(keys: keys, subjects: subject_list)
    end
  end

  def fetch(keys)
    InOrder::Fetch.new(keys).elements
  end

  def assert_elements_fetched(keys)
    keys = keys_list[keys.to_i] if Integer === keys or String === keys

    elements = @keys_by_elements[keys]

    assert_equal elements, fetch(keys)
  end

  before { @keys_by_elements = keys_list.zip(elements_list).to_h }

  it "fetches elements with owner/scope key" do
    assert_elements_fetched 0
  end

  it "fetches elements with owner/no_scope key" do
    assert_elements_fetched 1
  end

  it "fetches elements with scope key" do
    assert_elements_fetched 2
  end

  it "fetches elements with new_owner key" do
    assert_elements_fetched 3
  end

  it "fetches elements with new_owner/no_scope key" do
    assert_elements_fetched 4
  end
end

