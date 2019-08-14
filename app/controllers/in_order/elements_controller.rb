
module InOrder
  class ElementsController < ApplicationController
    include Concerns::GeneralMixins

    def create
      marker = InOrder::Element.find(element_params[:marker_id])

      InOrder::Insert.call(find_record, marker, element_params[:adjacency])

      respond_to_list #http_status(:created), true
    end

    def update
      target = params[:id]

      marker, adjacency = element_params.values_at(:marker_id, :adjacency)

      InOrder::Move.new(target, marker, adjacency).call

      respond_to_list
    end

    def destroy
      target = params[:id]

      InOrder::Remove.new(target).call

      respond_to_list
    end

    private

    def element_params
      params.require(:element).permit(*element_names)
    end

    def element_names
      %i(marker_id adjacency subject_type subject_id)
    end

    def record_key
      element_params.values_at(:subject_type, :subject_id)
    end
  end
end

