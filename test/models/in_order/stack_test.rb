
require 'test_helper'

describe InOrder::Stack do
  include ActiveSupport::Testing::Assertions
  include SetupElements

  STACK_SIZE = 5

  let(:stack) { InOrder::Stack.new(keys) }

  let(:queue) { InOrder::Queue.new(keys) }

  def subject(count=rand(99) + 100)
    Subject.create name: "Item #{count}"
  end

  def reduced_by_one
    { -> { InOrder::Element.count } => -1 }
  end

  def add_subjects(count)
    (1 .. count+1).map do |count|
      subject(count).tap {|subject| yield subject if block_given? }
    end
  end

  (0 .. STACK_SIZE).each do |count|
    it "pushes and pops to stack of size #{count}" do
      last_subject = nil

      add_subjects(count) do |subject|
        stack.push subject

        last_subject = subject
      end

      assert_difference reduced_by_one do
        assert_equal last_subject, stack.send(%i(call pop).sample)
      end
    end
  end

  it "trims to max size" do
    add_subjects(8) {|subject| stack.push subject }

    subject = subject()

    stack.push subject, 5

    assert_equal 5, stack.size
    assert_equal subject, stack.pop
  end

  it 'peeks' do
    subjects = add_subjects(3) {|subject| stack.push subject }

    assert_equal subjects.last, stack.peek
  end

  describe 'acting like a Queue' do
    it 'peeks' do
      subjects = add_subjects(3) {|subject| queue.join subject }

      assert_equal subjects.first, queue.peek
    end

    it "trims to max size" do
      subjects = add_subjects(8) {|subject| queue.add subject }

      queue.join subject, 5

      assert_equal 5, queue.size
      assert_equal subjects[5], queue.call
    end

    (0 .. STACK_SIZE).each do |count|
      it "puts in and takes out of queue of size #{count}" do
        first_subject = nil

        add_subjects(count) do |subject|
          queue.join subject

          first_subject ||= subject
        end

        assert_difference reduced_by_one do
          assert_equal first_subject, queue.send(%i(call leave take).sample)
        end
      end
    end
  end
end

