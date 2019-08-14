
module InOrder
  module Aux
    module SortElements
      module_function \
        def sort_elements(elements)
          index = elements.size

          sorted = Array.new(index)

          element_id = nil

          while index > 0
            index -= 1

            element = elements.find do |element|
                        element.element_id == element_id
                      end

            if element
              sorted[index] = element

              element_id = element.id
            end
          end

          sorted
        end
    end
  end
end

