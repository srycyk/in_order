
module InOrder
  # An element of a persisted linked-list 
  class Element < ApplicationRecord
    extend Aux::GetKeys

    self.table_name_prefix = 'in_order_'

    belongs_to :owner, optional: true, polymorphic: true

    belongs_to :subject, polymorphic: true

    belongs_to :element, optional: true

    scope :by_scope, -> (scope=nil) { where scope: scope }

    scope :by_owner, -> owner { where owner: owner }

    scope :by_owner_keys, -> (type, id) { where owner_type: type, owner_id: id }

    scope :by_subject, -> subject { where subject: subject }

    scope :by_subject_keys, -> (type, id) { where subject_type: type, subject_id: id }

    scope :by_keys, -> keys { by_scope(keys.scope).by_owner(keys.owner) }

    scope :by_element, -> element { where element_id: element.to_param }

    scope :include_all, -> { includes :subject, :owner }

    scope :fetch, -> keys { by_keys(keys).include_all }

    scope :null_element, -> { where element_id: nil }

    validate :validate_has_key_fields_valued

    alias call subject

    def to_s
      call.to_s
    end

    def as_json(*)
      super except: %i(created_at updated_at),
            #include: :subject,
            methods: :value
    end
    def value
      subject.as_json
    end

    def to_keys
      Aux::Keys.new(owner, scope)
    end

    def iterator
      Aux::ElementIterator.new(to_keys)
    end

    class << self
      def find_with_keys(*keys)
        keys = get_keys(keys)

        by_owner_keys(*keys.owner_key.to_a).by_scope(keys.scope)
      end
      alias find_with_key find_with_keys

      def fetch_with_keys(*keys)
        find_with_keys(keys).include_all
      end
      alias fetch_with_key fetch_with_keys

      def delete_elements(*keys)
        transaction do
          by_keys(get_keys keys).map {|element| element.destroy }
        end
      end

      def delete_list(*keys)
        by_keys(get_keys keys).delete_all
      end

      def first_element(*keys)
        keyed = by_keys(get_keys keys)

        if keyed.exists?
          keyed.where.not(id: keyed.pluck(:element_id)).first
        end
      end

      def last_element(*keys)
        by_keys(get_keys keys).null_element.first
      end

      def for_subject(*keys)
        poly_key = Aux::PolyKey.new(yield)

        by_keys(get_keys keys).by_subject_keys(*poly_key.to_a)
      end

      def has_subject?(*keys, &block)
        for_subject(keys, &block).exists?
      end

      def link_elements(end_of_former, beginning_of_latter)
        end_of_former.update_attribute :element, beginning_of_latter
      end
    end

    private

    def validate_has_key_fields_valued
      unless scope.present? or owner.present?
        errors[:base] << "Cannot leave both scope and owner blank"
      end
    end
  end
end

