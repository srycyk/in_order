
require 'test_helper'

describe InOrder::Create do
  include SetupElements

  it "persists all" do
    assert create_elements.all? {|element| element.persisted? }
  end

  it "creates all" do
    assert_equal subjects.size, create_elements.size
  end

  it "keeps elements in order" do
    assert_equal subjects, create_elements.map(&:subject)
  end

  it 'links new elements to the end of an existing list' do
    old_elements = create_elements(subjects: subjects)

    new_elements = create_elements(subjects: add_subjects)

    modified = fetch_elements

    assert_equal old_elements + new_elements, modified
  end

  it 'links new elements to the start of an existing list' do
    old_elements = create_elements(subjects: subjects)

    prepend_options = { options: { append: false } }

    new_elements = create_elements(subjects: add_subjects, **prepend_options)
 
    modified = fetch_elements

    assert_equal new_elements + old_elements, modified
  end
end

