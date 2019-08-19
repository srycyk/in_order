
module InOrder
  # Creates a list of elements for a given Owner and/or Scope,
  # which make up the key.
  # This list links a number of arbitrary *ActiveRecords* together,
  # retaining the given order (sequence).
  # Owner and Record are any ActiveRecord model (linked polymorphically).
  # The Scope is a string with an application-dependent value.
  # At least one of Owner and Scope must be given.
  # If a list of elememts with the same Owner/Scope combo already exists,
  # then the new elements will be appended to them,
  # unless the 'append' parameter is given as *false*,
  # in which case, they'll be prepended.
  class Create
    include Aux::VarKeys
    include Aux::CreateElement

    # +models+ are an Araay of ActiveRecord models to be linked
    def call(models, append: true)
      InOrder::Element.transaction do
        if append
          previous_last_element = InOrder::Element.last_element(keys)
        else
          previous_first_element = InOrder::Element.first_element(keys)
        end

        add_elements(models.dup).tap do |created_elements|
          if created_elements.any?
            if previous_first_element
              InOrder::Element.link_elements created_elements.last,
                                             previous_first_element
            elsif previous_last_element
              InOrder::Element.link_elements previous_last_element,
                                             created_elements.first
            end
          end
        end
      end
    end
    alias elements call

    def subjects(*args)
      call(*args).map &:subject
    end
    alias records subjects

    protected

    def add_elements(models, created=[], element_id=nil)
      if record = models&.pop
        element = create_element(record, keys, element_id)

        add_elements models, created, element.id

        created << element
      else
        created
      end
    end
  end
end

