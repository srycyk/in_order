
require 'test_helper'

describe InOrder::Remove do
  include ActiveSupport::Testing::Assertions
  include SetupElements

  POSITIONS = { first: 0, second: 1, left: 2, right: -2, last: -1 }

  def remove(to_remove, destroy: true)
    InOrder::Remove.new(to_remove, destroy: destroy).call
  end

  def element_counter(size_difference=-1)
    { -> { InOrder::Element.count } => size_difference }
  end

  it 'removes from list of one' do
    atts = keys.call subject: Subject.create(name: 'dropper')

    element = InOrder::Element.create(atts)

    assert_difference(element_counter) { remove(element) }

    assert_empty find_elements
  end

  it 'detaches from list, without element deletion' do
    elements = create_elements

    to_remove = elements.sample

    assert_difference(element_counter 0) { remove(to_remove, destroy: false) }

    refute to_remove.destroyed?

    # Ensures removed element is absent from list returned by subsequent calls
    to_remove.update owner: Owner.create(name: 'pen')

    assert_equal elements.size - 1, find_elements.size

    assert_equal elements - [to_remove], InOrder::Fetch.new(keys).elements
  end

  POSITIONS.each do |(name, index)|
    it "removes #{name} at #{index}" do
      to_remove = create_elements[index]

      assert_difference element_counter do
        remove(random? ? to_remove : to_remove.id)
      end

      refute present_in?(find_elements, to_remove)

      assert to_remove.destroyed?
    end
  end
end

