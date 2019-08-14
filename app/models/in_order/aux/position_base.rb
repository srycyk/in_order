
module InOrder
  module Aux
    class PositionBase
      include Aux::GetElement

      attr_accessor :target, :marker, :adjacency

      def initialize(target, marker, adjacency=nil)
        self.target = get_element target

        self.marker = get_element marker

        self.adjacency = adjacency.present? ? adjacency.to_sym : :after
      end

      private

      def after?
        adjacency == :after
      end
    end
  end
end

