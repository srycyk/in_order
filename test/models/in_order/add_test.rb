
require 'test_helper'

describe InOrder::Add do
  include ActiveSupport::Testing::Assertions
  include SetupElements

  let(:subject) { Subject.create name: 'calling' }

  def fetch(keys=keys())
    InOrder::Fetch.new(keys).elements
  end

  def add(beginning: false)
    InOrder::Add.new(keys).send(beginning ? :shift : :push, subject)
  end

  def assert_added_element
    assert_difference(-> { InOrder::Element.count } => 1 ) { yield }
  end

  it "appends" do
    create_elements

    assert_added_element { add }

    assert_equal subject, fetch.last.subject
  end

  it "prepends" do
    create_elements

    assert_added_element { add beginning: true }

    assert_equal subject, fetch.first.subject
  end

  it "appends to no list" do
    assert_added_element { add }

    assert_equal subject, fetch.last.subject
  end

  it "prepends to no list" do
    assert_added_element { add beginning: true }

    assert_equal subject, fetch.first.subject
  end
end

