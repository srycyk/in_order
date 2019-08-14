
require 'test_helper'

describe InOrder::Element do
  let(:owner) { Seed::Owners.new.call 1 }

  let(:subject) { Seed::Subjects.new.call 1 }

  let(:off_subject) { Subject.new name: 'matter' }

  let(:scope) { 'tele' }

  let :element do
    InOrder::Element.create owner: owner, scope: scope, subject: subject
  end

  let :root_element do
    InOrder::Element.create owner: owner, scope: scope,
                            subject: off_subject, element_id: element.id
  end

  let(:keys) { InOrder::Aux::Keys.new(owner, scope) }

  let(:default_atts) { keys.(subject: subject) }

  def new_element(**atts)
    atts.reverse_merge! default_atts

    InOrder::Element.new(atts)
  end

  def first_element
    InOrder::Element.first_element(keys)
  end
  def last_element
    InOrder::Element.last_element(keys)
  end

  it "persists" do
    assert element.persisted?

    refute_empty InOrder::Element.by_keys(keys)
  end

  it "finds one by keys" do
    element

    found = InOrder::Element.by_keys(keys)

    assert_equal element, found.first
  end

  it "finds two by keys" do
    root_element

    found = InOrder::Element.by_keys(keys)

    assert_includes found, root_element
    assert_includes found, element
  end

  it 'finds by owner given as hash' do
    element

    owner_hash = { owner_type: owner.class.name, owner_id: owner.id }

    keys = InOrder::Aux::Keys.new(owner_hash, scope)

    found = InOrder::Element.find_with_keys(keys)

    assert_equal found.first, element
  end

  it 'finds first with one in list' do
    element

    assert_equal first_element, element
  end

  it 'finds first with two in list' do
    root_element

    assert_equal first_element, root_element
  end

  it 'finds last with one in list' do
    element

    assert_equal last_element, element
  end

  it 'finds last with two in list' do
    root_element

    assert_equal last_element, element
  end

  it 'returns nil if list empty on first' do
    assert_nil first_element
  end

  it 'returns nil if list empty on last' do
    assert_nil last_element
  end

  it "returns subject on call" do
    assert_equal subject, element.call
  end

  it 'deletes whole list' do
    root_element

    assert InOrder::Element.delete_elements(keys).all?(&:destroyed?)

    assert_empty InOrder::Element.by_keys(keys)
  end

  it "shows to_s of subject" do
    assert_equal subject.to_s, element.to_s
  end

  it "extracts keys" do
    assert_equal keys, element.to_keys
  end

  describe 'subject in keyed list' do
    it 'is found' do
      element

      is_found = InOrder::Element.has_subject?(keys) { subject }

      assert is_found
    end

    it 'is not found' do
      is_found = InOrder::Element.has_subject?(keys) { subject }

      refute is_found
    end
  end

  describe 'validation' do
    it 'is okay with all fields valued' do
      assert new_element.valid?
    end

    it 'needs subject' do
      refute new_element(subject: nil).valid?
    end

    it 'needs key' do
      refute new_element(scope: nil, owner: nil).valid?
    end

    it 'can have scope as key' do
      assert new_element(owner: nil).valid?
    end

    it 'can have owner as key' do
      assert new_element(scope: nil).valid?
    end
  end
end

