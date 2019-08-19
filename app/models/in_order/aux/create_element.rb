
module InOrder
  module Aux
    module CreateElement
      private

      def create_element(subject, keys, element_id=nil)
        poly_key = Aux::PolyKey.new(subject, name: :subject)

        atts = keys.(poly_key.to_params.merge element_id: element_id)

        InOrder::Element.create(atts)
      end
    end
  end
end

