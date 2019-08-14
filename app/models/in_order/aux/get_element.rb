
module InOrder
  module Aux
    module GetElement
      private

      def get_element(element_candidate)
        if InOrder::Element === element_candidate
          element_candidate
        elsif element_candidate
          InOrder::Element.find(element_candidate)
        end
      end
    end
  end
end

