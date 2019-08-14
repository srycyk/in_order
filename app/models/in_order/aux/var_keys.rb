
module InOrder
  module Aux
    module VarKeys
      include GetKeys

      def self.included(base)
        base.instance_eval { attr_accessor :keys }
      end
 
      # +keys+ InOrder::Keys or an Array, used as constructor args to former
      def initialize(*keys)
        super()

        self.keys = get_keys(keys)
      end
    end
  end
end

