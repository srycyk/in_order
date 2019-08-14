
# A first in, last out queue.
module InOrder
  class Queue
    include Aux::VarKeys

    def join(record, max=nil)
      adder.prepend(record).tap { trim(max) if max }
    end
    alias add join

    def call
      remove_element
    end
    alias leave call
    alias take call

    def peek
      last_element&.subject
    end

    def trim(max, take_last=is_queue?)
      if size > max
        if take_last
          remove_element
        else
          remove_element { first_element }
        end

        trim max, take_last
      end
    end

    def size
      InOrder::Element.by_keys(keys).count
    end

    private

    def last_element
      InOrder::Element.last_element(keys)
    end

    def first_element
      InOrder::Element.first_element(keys)
    end

    def remove_element
      if element = (block_given? ? yield : last_element)
        Remove.new(element).call

        element.subject
      end
    end

    def adder
      Add.new(keys)
    end

    def is_queue?
      InOrder::Queue == self.class
    end
  end
end

