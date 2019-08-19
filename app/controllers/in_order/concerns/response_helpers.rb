
module InOrder
  module Concerns::ResponseHelpers
    private

    def respond_to_list(status=:ok, send_nothing_back=false)
      respond_to do |format|
        format.html { render partial_name }

        format.js { render partial_name }

        if send_nothing_back
          #format.json { render nothing: true, status: status }
          format.json { head status }
        else
          format.json do
            #render json: (@elements ||= []), include: :subject, status: status
            render json: (@elements ||= []), status: status
          end
        end
      end
    end

    def http_status(status=:ok)
      status ? status : :unprocessable_entity
    end

    def partial_name
      params[:partial_name] or params[:partial] or 'index'
    end
  end
end

