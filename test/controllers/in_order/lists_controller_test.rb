
require 'test_helper'

module InOrder
  class ListsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    #setup do
    #  @routes = Engine.routes
    #end

    include ModelsFunctions
    include SetupFunctions
    include ControllerFunctions

    NUM_RECORDS = 3

    # Key params
    def owner_params(type=nil, id=nil, owner: nil)
      poly_key(owner || [type, id], default_name: :owner).to_params
    end

    def scope_params(scope=scope())
      { scope: scope }
    end

    def element_key_params(owner=owner())
      owner_params(owner: owner).merge(scope_params)
    end

    # Record params
    def record_keys_params(records=record_keys())
      records = record_keys records if Integer === records

      { record_keys: records }
    end

    def record_keys(count=1)
      create_subjects(count).map do |subject|
        record_key(subject)
      end
    end

    def record_key(record, type: :s)
      poly_key(record).send "to_#{type}"
    end

    def list_params(**record_params)
      { list: record_params }
    end

    def assert_owner(owner, atts)
      assert owner.class.name, atts['owner_type']

      assert owner.to_param, atts['owner_id']
    end

    # Index

    test 'index: empty params' do
      get lists_path, request_options({})

      assert_empty_array response.body
    end

    test 'index: empty list params' do
      get lists_path, request_options(list_params)

      assert_empty_array response.body
    end

    test 'index: by scope' do
      create_elements keys: new_keys(**scope_params)

      options = request_options list_params(scope_params)

      get lists_path, options

      assert_equal scope, json_record(response)['scope']
    end

    test 'index: by owner' do
      create_elements keys: new_keys(owner)

      options = request_options list_params(owner_params owner: owner)

      get lists_path, options

      assert_owner owner, json_record(response)
    end

    test 'index: by an owner with no attached list' do
      options = request_options list_params(owner_params owner: owner)

      get lists_path, options

      assert_empty_array response.body
    end

    test 'index: by blank-field owner' do
      create_elements keys: new_keys(owner)

      options = request_options list_params(owner_params '', '')

      get lists_path, options

      assert_empty_array response.body
    end

    test 'index: by both owner and scope' do
      create_elements

      options = request_options list_params(element_key_params)

      get lists_path, options

      record_atts = json_record(response)

      assert scope, record_atts['scope']
      assert_owner owner, record_atts
    end

    test 'index: fetches first and record' do
      create_elements

      options = request_options list_params(element_key_params)

      get lists_path, options

      #record_atts = json_record(response)

      assert_equal NAME_TEMPLATE % 1, json_record(response, dig: 'name')

      assert_equal NAME_TEMPLATE % DEFAULT_COUNT,
                   json_record(response, -1, dig: 'name')
    end

    # Create

    test 'create: with no records' do
      options = request_options list_params(element_key_params)

      post lists_path, options

      assert_empty_array response.body
    end

    test 'create: with empty records' do
      create_params = element_key_params.merge(record_keys_params [])

      options = request_options list_params(create_params)

      post lists_path, options

      assert_empty_array response.body
    end

    (1 .. NUM_RECORDS).each do |num_records|
      test "create: with #{num_records} records" do
        create_params = element_key_params.merge(record_keys_params num_records)

        options = request_options list_params(create_params)

        post lists_path, options

        assert_equal RECORD_TEMPLATE % num_records,
                     json_record(response, -1, dig: 'name')
      end
    end

    # Destroy

    test 'destroy: by element_id' do
      elements = create_elements

      options = request_options

      assert_difference  -> { InOrder::Element.count } => -elements.size do
        delete list_path(elements.first.id), options
      end

      assert_equal '200',response.code
    end

    # Remove

    test 'remove: by keys' do
      elements = create_elements

      options = request_options list_params(element_key_params)

      assert_difference  -> { InOrder::Element.count } => -elements.size do
        post remove_lists_path, options
      end

      assert_equal '200', response.code
    end

    # Add

    PREPENDERS = %w(prepend before)

    [ nil, 'after', PREPENDERS.sample ].each do |position|
      test "add: new elements with #{position || :default_append}" do
        create_elements

        new_subjects = subjects(1, start: 10)

        record_params = new_subjects.map {|subject| record_key subject }
        add_params = element_key_params.merge(record_keys_params record_params)

        options = request_options list_params(add_params.merge position: position)

        post add_lists_path, options

        will_prepend = PREPENDERS.include?(position)

        first_name = NAME_TEMPLATE % (will_prepend ? 10 : 1)
        last_name = NAME_TEMPLATE % (will_prepend ? 3 : 11)

        assert_equal first_name, json_record(response, dig: 'name')
        assert_equal last_name, json_record(response, -1, dig: 'name')
      end
    end

    test "add: trims to max elements" do
      new_subjects = subjects(6)

      record_params = new_subjects.map {|subject| record_key subject }
      add_params = element_key_params.merge(record_keys_params record_params)

      options = request_options list_params(add_params.merge max: 3)

      post add_lists_path, options

      assert_equal 3, json_parse(response).size
    end
  end
end
