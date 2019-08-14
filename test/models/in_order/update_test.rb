
require 'test_helper'

describe InOrder::Update do
  include SetupElements

  def update_elements(keys: keys(), subjects: subjects(),
                      append: true, max: nil, uniq: false)
    InOrder::Update.new(keys)
      .call(subjects, append: append, max: max, uniq: uniq)
  end

  it "persists all" do
    assert update_elements.all? {|element| element.persisted? }
  end

  it "updates all" do
    assert_equal subjects.size, update_elements.size
  end

  it "keeps elements in order" do
    assert_equal subjects, update_elements.map(&:subject)
  end

  it 'links new elements to the end of an existing list' do
    old_subjects = update_elements(subjects: subjects).map(&:subject)

    added_subjects = add_subjects

    new_elements = update_elements(subjects: added_subjects)

    assert old_subjects + added_subjects, new_elements.map(&:subject)
  end

  it 'links new elements to the start of an existing list' do
    old_subjects = update_elements(subjects: subjects).map(&:subject)

    added_subjects = add_subjects

    new_elements = update_elements(subjects: added_subjects, append: false)
 
    assert added_subjects + old_subjects, new_elements.map(&:subject)
  end

  it 'trims down to size' do
    elements = update_elements(max: 3)

    assert_equal 3, elements.size
  end

  it 'trims from top if append' do
    added_subjects = add_subjects(6)

    elements = update_elements(subjects: added_subjects, max: 3)

    assert_equal added_subjects[3], elements.first.subject
  end

  it 'trims from bottom if prepend' do
    added_subjects = add_subjects(6)

    elements = update_elements(subjects: added_subjects, max: 3, append: false)

    assert_equal added_subjects[2], elements.last.subject
  end

  it 'removes duplicated subjects from previous list' do
    update_elements

    elements = update_elements uniq: true

    assert_equal subjects.size, elements.size
  end

  it 'keeps duplicated subjects in previous list' do
    update_elements

    elements = update_elements uniq: false

    assert_equal subjects.size * 2, elements.size
  end
end

