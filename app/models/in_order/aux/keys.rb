
module InOrder
  module Aux
    class Keys
      attr_accessor :scope, :owner

      def initialize(_owner=nil, _scope=nil, owner: _owner, scope: _scope)
        self.owner = owner

        self.scope = scope
      end

      def call(**extras)
        to_params.merge extras
      end

      def valid?
        to_a.any?
      end

      def to_h
        owner_params.merge scope_params
      end
      alias to_params to_h

      def to_s
        to_a.compact.map(&:to_s) * ', '
      end

      def to_a
        [ owner, scope ]
      end

      def owner_params
        owner_key.to_params
      end

      def scope_params
        { scope: scope }
      end

      def owner_key
        InOrder::Aux::PolyKey.new(owner, default_name: 'owner')
      end

      def ==(other)
        to_a == other.to_a
      end

      private

      def hash
        to_a.hash
      end
    end
  end
end

