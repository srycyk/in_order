
module InOrder
  # Puts a new element anywhere in a pre-exising list.
  class Insert < Aux::PositionBase
    def call
      InOrder::Element.transaction do
        if marker
          if after?
            target.update element_id: marker.element_id

            marker.update element_id: target.id
          else
            if previous = InOrder::Element.find_by(element_id: marker.id)
              previous.update element_id: target.id
            end

            target.update element_id: marker.id
          end
        end
        target
      end
    end

    def self.call(record, marker, adjacency)
      element = Add.new(marker.to_keys).element(record)

      new(element, marker, adjacency).call
    end
  end
end

