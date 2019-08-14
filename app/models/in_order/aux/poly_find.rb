
module InOrder
  module Aux
    class PolyFind
      attr_accessor :poly_key

      def initialize(*args)
        self.poly_key = args.first if InOrder::Aux::PolyKey === args.first

        self.poly_key ||= PolyKey.new(*args)
      end

      def call
        poly_key.type.constantize.find poly_key.id if poly_key.valid?
      end

      def self.call(keys)
        (keys || []).map {|key| new(key).call }
          .compact
      end
    end
  end
end

