
require 'test_helper'

describe InOrder::Trim do
  include SetupElements

  MAX = 4

  def elements
    @elements
  end

  def trim(max: MAX, take_from: :bottom, destroy: true)
    InOrder::Trim.new(max, destroy: destroy, take_from: take_from)
      .call(elements)
  end

  before { @elements = create_elements }

  (MAX-1 .. MAX+1).each do |max|
    [ true, false ].each do |destroy|
      destroyer = "with#{destroy ? '' : 'out'} destroy"

      assertion = destroy ? :assert : :refute

      it "trims to #{max} from top #{destroyer}" do
        trimmed = trim(max: max, take_from: :top, destroy: destroy)

        assert max, trimmed.size

        assert_equal elements[elements.size - max], trimmed.first
        assert_equal elements.last, trimmed.last

        send assertion, elements.first.destroyed?
        refute_nil elements.first.element_id
      end

      it "trims to #{max} from bottom #{destroyer}" do
        trimmed = trim(max: max, take_from: :bottom, destroy: destroy)

        assert max, trimmed.size

        assert_equal elements.first, trimmed.first
        assert_equal elements[max - 1], trimmed.last

        send assertion, elements.last.destroyed?
        assert_nil elements.last.element_id
      end
    end
  end
end

