
module InOrder
  module Aux
    class ElementIterator
      include Enumerable

      include Comparable

      include Aux::VarKeys

      def initialize(*args)
        super if args.any?
      end

      def each(current=get_first, &block)
        if block
          if current
            yield current

            each current.element, &block
          end 
        else
          to_enum :each
        end
      end

      def <=>(other)
        subject <=> other.subject
      end

      private

      def get_first
        InOrder::Element.first_element(keys) if keys
      end
    end
  end
end

