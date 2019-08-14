
require 'test_helper'

describe InOrder::Insert do
  include SetupElements

  let(:subject) { Subject.create name: 'of the game' }

  let(:element) { InOrder::Element.create keys.call(subject: subject) }

  def insert(marker, adjacency=:after, insertion: element)
    InOrder::Insert.new(insertion, marker, adjacency).call
  end

  def assert_insertion(adjacency, marker_index, insertion_index=marker_index)
    elements = create_elements

    insertion = insert(elements[marker_index], adjacency)

    newly_found = InOrder::Fetch.new(keys).elements

    assert_equal insertion, newly_found[insertion_index]

    assert_equal elements.size + 1, newly_found.size
  end

  it 'inserts into empty list' do
    elements = [ element ]

    assert_equal elements, find_elements
  end

  it 'inserts into empty list with a nil marker' do
    insert(nil, insertion: element)

    assert_equal [ element ], find_elements
  end

  it 'inserts before first' do
    assert_insertion :before, 0
  end

  it 'inserts after first' do
    assert_insertion :after, 0, 1
  end

  it 'inserts before second' do
    assert_insertion :before, 1
  end

  it 'inserts after second' do
    assert_insertion :after, 1, 2
  end

  it 'inserts before 2nd last' do
    assert_insertion :before, -2, -3
  end

  it 'inserts after 2nd last' do
    assert_insertion :after, -2
  end

  it 'inserts before last' do
    assert_insertion :before, -1, -2
  end

  it 'inserts after last' do
    assert_insertion :after, -1
  end
end

