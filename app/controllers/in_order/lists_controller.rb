
module InOrder
  class ListsController < ApplicationController
    include Concerns::GeneralMixins

    def index
      @elements = InOrder::Fetch.new(keys).elements

      respond_to_list
    end

    def create
      @elements = InOrder::Create.new(keys).(find_records)

      respond_to_list http_status(:created)
    end

    def destroy
      if element = InOrder::Element.find_by_id(params[:id])
        delete_by_keys element.to_keys
      end

      respond_to_list http_status(:accepted), true
    end

    def remove
      delete_by_keys keys

      respond_to_list http_status(:accepted), true
    end

    def add
      update = InOrder::Update.new(keys)

      @elements = update.(find_records,
                          append: append_to_existing_list?,
                          uniq: uniq?, max: max)

      respond_to_list http_status
    end

    private

    def append_to_existing_list?
      param = list_params[:position]

      #param.blank? or param =~ /after/i
      param.blank? || param =~ /after/i ? true : false
    end

    def max
      list_params[:max]
    end

    FALSITIES = %w(f false 0 n no)
    def uniq?
      uniq = list_params[:uniq]

      uniq != false and (uniq.blank? or FALSITIES.exclude?(uniq.strip))
    end

    def delete_by_keys(delete_keys)
      InOrder::Element.delete_elements delete_keys
    end

    def list_params
      params.fetch(:list).permit(*list_names)
    end

    def list_names
      [ :scope, :owner_type, :owner_id, # keys for element list
        :position, :max, # for add action
        record_keys: [] ] # records to attach
    end

    def record_keys
      list_params[:record_keys]
    end

    def record_key
      #[ list_params[:type], params[:id] ].compact
      super list_params
    end
  end
end

