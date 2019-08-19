
module InOrder
  # Puts a new element anywhere in a pre-exising list.
  class Insert < Aux::PositionBase
    extend Aux::CreateElement
    extend Aux::GetElement

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

    def self.call(record, marker, adjacency, keys: nil)
      keys = InOrder::Aux::Keys.new(*keys) if Array === keys

      unless ActiveRecord::Base === record
        record = InOrder::Aux::PolyFind.new(record).call
      end

      marker = get_element(marker)

      element = create_element(record, keys || marker.to_keys)

      new(element, marker, adjacency).call
    end
  end
end

