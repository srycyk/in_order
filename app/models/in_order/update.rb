
module InOrder
  # Adds new elements to an existing list, returning the whole new list.
  # Effectively, it calls Create, Fetch Uniq and Trim.
  class Update
    include Aux::VarKeys

    include Aux::SortElements

    attr_accessor :append, :uniq, :max
    alias append? append
    alias uniq? uniq

    def set_options(append: true, uniq: true, max: nil)
      self.append = append

      self.max = max&.to_i

      self.uniq = uniq
    end

    def call(models, **options)
      set_options(**options)

      previous_elements = get_elements

      if uniq? and previous_elements.any?
        if purge_previous(previous_elements, models)
          previous_elements = get_elements
        end
      end

      new_elements = Create.new(keys).(models, append: append?)

      if previous_elements.any?
        new_elements = add_to_list(previous_elements, new_elements)
      end

      trim(new_elements)
    end
    alias elements call

    def subjects(*args)
      call(*args).map &:subject
    end
    alias records subjects

    private

    def purge_previous(previous_elements, models)
      Purge.new(keys).remove(*models, elements: previous_elements)
    end

    def get_elements
      sort_elements(InOrder::Element.fetch(keys).to_a)
    end

    def create_options
      { append: append? }
    end

    def add_to_list(previous_elements, new_elements)
      if append?
        previous_elements.last.reload

        previous_elements + new_elements
      else
        new_elements + previous_elements
      end
    end

    def trim(elements)
      if max.present?
        take_from = append? ? :top : :bottom

        elements = Trim.new(max, take_from: take_from).(elements)
      end

      elements
    end
  end
end

