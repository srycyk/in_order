
require 'test_helper'

describe InOrder::Create do
  include SetupElements

  def elements
    @elements
  end

  def fetch(keys=keys())
    InOrder::Fetch.new(keys).elements
  end

  def move(insertion, marker, adjacency)
    InOrder::Move.new(insertion, marker, adjacency).call
  end

  def assert_moved(from_index, to_index, adjacency, target_index=to_index)
    from, to = elements.values_at(from_index, to_index)

    move(from, to, adjacency)

    found = fetch

    assert_equal found[target_index], from

    assert_equal elements.size, found.size
  end

  before { @elements = create_elements }

  SECOND, FIRST, LAST, SECOND_LAST = 1, 0, -1, -2

  it "moves first to last" do
    assert_moved FIRST, LAST, :after
  end

  it "moves last to first" do
    assert_moved LAST, FIRST, :before
  end

  it "moves first to second" do
    assert_moved FIRST, SECOND, :after
  end

  it "moves second to first" do
    assert_moved SECOND, FIRST, :before
  end

  it "moves second last to first" do
    assert_moved SECOND_LAST, FIRST, :before
  end

  it "moves second last to second" do
    assert_moved SECOND_LAST, SECOND, :before

    assert_moved SECOND_LAST, FIRST, :after, SECOND
  end

  it "moves second to second last" do
    assert_moved SECOND, LAST, :before, SECOND_LAST

    assert_moved SECOND, SECOND_LAST, :after
  end

  it "moves second last to last" do
    assert_moved SECOND_LAST, LAST, :after
  end

  it "moves last to second last" do
    assert_moved LAST, SECOND_LAST, :before
  end
end

