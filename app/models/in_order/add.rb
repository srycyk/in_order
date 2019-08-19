
module InOrder
  # Adds a new element at the beginning or end of a list.
  # Identified (i.e. keyed) by an Owner and/or Scope.
  class Add
    include Aux::VarKeys
    include Aux::CreateElement

    # +model+ is an ActiveRecord model to be linked
    def call(model, at: :bottom)
      bottom?(at) ? append(model) : prepend(model)
    end

    def prepend(model)
      insert model, :before, first_element
    end
    alias shift prepend

    def append(model)
      insert model, :after, last_element
    end
    alias push append

    def insert(model, adjacency=nil, marker=nil)
      marker = block_given? ? yield(iterator, model, adjacency, marker) : marker

      InOrder::Element.transaction do
        Insert.new(create_element(model, keys), marker, adjacency).call
      end
    end

    private

    def bottom?(at)
      at.nil? or %i(bottom last end).include?(at.to_sym)
    end

    def first_element
      InOrder::Element.first_element(keys)
    end

    def last_element
      InOrder::Element.last_element(keys)
    end

    def iterator
      Aux::ElementIterator.new(keys)
    end
  end
end

