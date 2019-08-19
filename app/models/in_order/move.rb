
module InOrder
  # Repositions an existing list element.
  # Can be used in drag'n'drop lists.
  class Move < Aux::PositionBase
    def call
      InOrder::Element.transaction do
        Remove.new(target, destroy: false).call

        Insert.new(target, marker, adjacency).call
      end
    end
  end
end

