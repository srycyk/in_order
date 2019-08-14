
module InOrder
  # Ensures a list does not exceed a specified length
  class Trim
    include Aux::SortElements

    attr_accessor :destroy, :max, :take_from
    alias destroy? destroy

    def initialize(_max=nil, destroy: true, take_from: :bottom, max: _max)
      self.destroy = destroy

      self.max = max&.to_i

      self.take_from = take_from
    end

    def call(elements, max_size=max)
      return unless max_size

      elements = elements.dup

      InOrder::Element.transaction do
        while elements.size > max_size.to_i
          if take_from == :bottom
            delete elements.pop

            unlink elements.last
          else
            delete elements.shift
          end
        end
      end
      elements
    end

    class << self
      mattr_accessor :maximum, default: 10

      def call(*keys)
        elements = InOrder::Fetch.new(*keys).elements

        args = block_given? ? yield : [ maximum, destroy: false ]

        InOrder::Trim.new(*args).call(elements).map(&:subject)
      end

      def set_max(max)
        self.maximum = max

        self
      end
    end

    private

    def delete(element)
      element.destroy if destroy? and is_an_element!(element)
    end

    def unlink(element)
      element.update(element_id: nil) if destroy?
    end

    def is_an_element!(element)
      if InOrder::Element === element
        true
      else
        raise "Cannot trim: #{element.class} is not an instance of InOrder::Element"
      end
    end
  end
end

