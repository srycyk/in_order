
module SetupFunctions
  RECORD_TEMPLATE = 'Record %s'
  ADDED_TEMPLATE = 'Added %s'
  DEFAULT_COUNT = 3

  def poly_key(*args)
    InOrder::Aux::PolyKey.new(*args)
  end

  def create_subjects(count=DEFAULT_COUNT, template: RECORD_TEMPLATE)
    (1..count).map do |count|
      name = template % count

      create_subject(name)
    end
  end

  def create_subject(name)
    Subject.create(name: name)
  end

  def add_subjects(count=3)
    create_subjects(count, template: ADDED_TEMPLATE)
  end

  def fetch_elements
    InOrder::Fetch.new(keys).elements
  end

  def show(element)
    "(#{element} -> #{element.element}) "
  end
  def list(list)
    list.map(&method(:show)).inspect
  end
=begin
=end

  def new_keys(*args)
    InOrder::Aux::Keys.new(*args)
  end
  def keys(owner: owner(), scope: scope())
    new_keys owner, scope
  end

  def create_owner(name='ah')
    Owner.create name: name
  end

  def create_elements(keys: keys(), subjects: subjects(), options: {})
    InOrder::Create.new(keys).(subjects, **options)
  end

  def find_elements(keys=keys())
    InOrder::Element.by_keys(keys).reload.to_a
  end

  def random?
    rand(1).zero?
  end

  def present_in?(elements, target)
    elements.find {|element| element == target }
  end
end

