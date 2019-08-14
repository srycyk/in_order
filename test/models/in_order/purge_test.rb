
require 'test_helper'

describe InOrder::Purge do
  include ActiveSupport::Testing::Assertions
  include SetupElements

  def elements
    @elements
  end

  def subject(index=nil, min: 0, max: subjects.size)
    index ||= rand(min ... max)

    subjects[index]
  end

  def add_subject(subject, action=:append)
    InOrder::Add.new(keys).send(action, subject)
  end

  def purge
    InOrder::Purge.new(keys)
  end

  def fetch
    InOrder::Fetch.new(keys).elements
  end

  def fetch_subjects
    fetch.map &:subject
  end

  def reduced_by(number)
    { -> { InOrder::Element.count } => -number }
  end

  before do
    @elements = create_elements(subjects: subjects)
  end

  it "removes trailing duplicates" do
    subject = subject(min: 1)

    add_subject(subject, :prepend)

    assert_difference reduced_by 1 do
      purge.call
    end

    assert_equal subject, fetch.first.subject
  end

  it "removes leading duplicates" do
    subject = subject(max: subjects.size - 1)

    add_subject(subject)

    assert_difference reduced_by 1 do
      purge.call keep_last: true
    end

    assert_equal subject, fetch.last.subject
  end

  it "removes multiple duplicates" do
    subject = subject()

    add_subject(subject)
    add_subject(subject, :prepend)

    assert_difference reduced_by 2 do
      purge.call
    end

    assert_includes fetch_subjects, subject
  end

  it "removes all subjects" do
    subject = subject()

    add_subject(subject)
    add_subject(subject, :prepend)

    assert_difference reduced_by 3 do
      purge.remove subject
    end

    refute_includes fetch_subjects, subject
  end
end

