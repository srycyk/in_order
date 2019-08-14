
module InOrder
  # Returns a list of elements in order, given a key of Owner and/or Scope.
  class Fetch
    include Aux::VarKeys

    include Aux::SortElements

    def call
      elements.map &:subject
    end

    def elements
      sort_elements fetch
    end

    def repair
      InOrder::Element.transaction do
        fetch.each do |element|
          if element.subject.nil?
            Remove.new(element).call
          end
        end
      end
      self
    end

    def fetch
      InOrder::Element.fetch_with_key(keys).to_a
    end
  end
end

