
require 'test_helper'

module InOrder
  class ElementsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    include ModelsFunctions
    include SetupFunctions
    include ControllerFunctions

    NUM_RECORDS = 6

    def elements
      @elements
    end

    def subjects
      @subjects
    end

    def subject
      @subject ||= create_subject('New subject')
    end

    def subject_params
      { subject_type: subject.class.name, subject_id: subject.id }
    end

    def element_params(**element_params)
      { element: element_params }
    end

    setup do
      @subjects = create_subjects(NUM_RECORDS)

      @elements = create_elements(subjects: @subjects)
    end

    #teardown { @subjects, @elements, @subject = [] }

    # Create

    test 'create: add record at start' do
      position_params = { marker_id: elements.first.id, adjacency: :before }

      params = subject_params.merge position_params

      options = request_options element_params(params)

      post elements_path, options

      assert_equal subject, fetch_elements.first.subject
    end

    test 'create: add record at end' do
      position_params = { marker_id: elements.last.id, adjacency: :after }

      params = subject_params.merge position_params

      options = request_options element_params(params)

      post elements_path, options

      assert_equal subject, fetch_elements.last.subject
    end

    (1 ... NUM_RECORDS).each do |index|
      test "create: add record after index #{index}" do
        position_params = { marker_id: elements[index].id, adjacency: :after }

        params = subject_params.merge position_params

        options = request_options element_params(params)

        post elements_path, options

        assert_equal subject, fetch_elements[index + 1].subject
      end
    end

    (0 ... NUM_RECORDS - 1).each do |index|
      test "create: add record before index #{index}" do
        position_params = { marker_id: elements[index].id, adjacency: :before }

        params = subject_params.merge position_params

        options = request_options element_params(params)

        post elements_path, options

        assert_equal subject, fetch_elements[index].subject
      end
    end

    # Update

    test 'update: move first to last' do
      first, _ = elements.values_at(0, -1)

      position_params = { marker_id: elements[-1].id, adjacency: :after }

      options = request_options element_params(position_params)

      put element_path(first), options

      assert_equal first, fetch_elements[-1]
    end

    test 'update: move last to first' do
      _, last = elements.values_at(0, -1)

      position_params = { marker_id: elements[0].id, adjacency: :before }

      options = request_options element_params(position_params)

      put element_path(last), options

      assert_equal last, fetch_elements[0]
    end

    (1 .. NUM_RECORDS - 2).each do |start_index|
      test "update: move element #{start_index} after a later one" do
        to_index = rand(start_index + 1 ... elements.size)

        target, _ = elements.values_at(start_index, to_index)

        position_params = { marker_id: elements[to_index].id, adjacency: :after }

        options = request_options element_params(position_params)

        put element_path(target), options

        assert_equal target, fetch_elements[to_index]
      end
    end

    # Destroy

    (0 ... NUM_RECORDS).each do |index|
      test "destroy: by element_id at index #{index}" do
        element = elements[index]
      
        options = request_options

        assert_difference  -> { InOrder::Element.count } => -1 do
          delete element_path(element.id), options
        end

        assert_equal elements - [element], fetch_elements
      end
    end
  end
end

