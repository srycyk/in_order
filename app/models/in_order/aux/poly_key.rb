
module InOrder
  module Aux
    class PolyKey
      FIELD_NAMES = %i(type id)

      SPLITTER_RE = %r([-,:/^\\|\s])

      attr_accessor :type, :id, :default_name

      def initialize(candidate, id=nil, name: nil, default_name: name)
        self.default_name = default_name

        candidate = [ candidate, id ] if id

        assign candidate
      end

      def to_s(delim='-')
        "#{type}#{delim}#{id}"
      end
      alias to_param to_s
      alias to_key to_s

      def to_a
        [ type, id ]
      end

      def to_h(field_names=full_names)
        field_names.zip(to_a).to_h
      end
      alias to_params to_h

      def to_bare_params
        to_h FIELD_NAMES
      end
      alias to_short_params to_bare_params

      # REST key params
      def to_id_key_params
        { id: to_s }
      end
      def to_id_params
        { id: id }
      end
      def to_type_params
        { type: type }
      end

      def to_params_by_name(key_name=nil, default: true)
        key_name ||= name_prefix

        { key_name.to_sym => to_bare_params }
      end
      #alias to_named params to_params_by_name

      def set(type=nil, _id=nil, id: _id)
        self.type = type.to_s if type

        self.id = id

        self
      end

      def valid?
        type.present? and id.present?
      end

      protected

      def type_name
        type.demodulize.underscore if type
      end

      def name_prefix
        default_name or type_name
      end

      def full_name(suffix)
        "#{name_prefix}_#{suffix}".to_sym
      end

      def full_names
        return full_name(:type), full_name(:id)
      end

      private

      def assign(key)
        case key
        when String
          set(*key.split(SPLITTER_RE))
        when Array
          set(*key)
        when Hash
          try_to_set_from_hash(key)
        when model?
          set(key.class, key.to_param)
        end
      end

      def model?
        -> whatever { whatever.respond_to?(:to_model) }
      end

      def try_to_set_from_hash(key)
        set_from_hash(key, FIELD_NAMES)

        set_from_hash(key, full_names) if not valid? and name_prefix
      end
      def set_from_hash(key, name_args)
        set(*key.values_at(*name_args))
      end
    end
  end
end

