
module InOrder
  module Aux
    module GetKeys
      private

      def get_keys(keys)
        if keys&.any?
          if keys_instance? keys[0]
            keys[0]
          elsif Array === keys[0] and keys_instance? keys[0][0]
            keys[0][0]
          else
            InOrder::Aux::Keys.new(*keys)
          end
        end
      end

      private

      def keys_instance?(candidate)
        InOrder::Aux::Keys === candidate
      end
    end
  end
end

