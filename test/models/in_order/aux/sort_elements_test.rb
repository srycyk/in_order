
require 'test_helper'

describe InOrder::Aux::SortElements do
  include SetupElements

  def sort(elements)
    InOrder::Aux::SortElements.sort_elements(elements)
  end

  it "handles empty list" do
    assert_empty sort([])
  end

  it "handles single item list" do
    list = [ InOrder::Element.new ]

    assert_equal list, sort(list)
  end

  it "leaves sorted list alone" do
    elements = create_elements

    assert_equal elements, sort(elements)
  end

  it "sorts shuffled elements" do
    elements = create_elements.shuffle

    refute_equal subjects, elements.map(&:subject)

    assert_equal subjects, sort(elements).map(&:subject)
  end
end

