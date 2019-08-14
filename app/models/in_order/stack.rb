
# A first in, first out queue.
module InOrder
  class Stack < InOrder::Queue
    def push(record, max=nil)
      adder.append(record).tap { trim(max) if max }
    end

    alias pop call
  end
end

