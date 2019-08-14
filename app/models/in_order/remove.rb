
module InOrder
  # Takes an element out of a list
  class Remove
    include Aux::GetElement

    attr_accessor :element_id, :destroy
    alias destroy? destroy

    def initialize(element_id, destroy: true)
      self.element_id = element_id

      self.destroy = destroy
    end

    def call
      InOrder::Element.transaction do
        element = get_element element_id

        if previous = InOrder::Element.find_by(element_id: element.id)
          previous.update element_id: element.element_id
        end

        element.tap {|element| element.destroy if destroy? }
      end
    end
  end
end

