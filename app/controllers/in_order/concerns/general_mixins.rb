
module InOrder
  module Concerns::GeneralMixins
    private

    def respond_to_list(status=:ok, send_nothing_back=false)
      respond_to do |format|
        format.html { render partial_name }

        format.js { render partial_name }

        if send_nothing_back
          #format.json { render nothing: true, status: status }
          format.json { head :ok }
        else
          format.json do
            #render json: @elements || [], include: :subject, status: status
            render json: (@elements ||= []), status: status
          end
        end
      end
    end

    def http_status(status=:ok, in_error=false)
     in_error ? status : :unprocessable_entity
    end

    def keys
      @keys ||= InOrder::Aux::Keys.new(*keys_args.compact)
    end
    def keys_args
      return find_owner, scope: list_params[:scope]
    end

    def find_owner
      record_key = list_params.values_at :owner_type, :owner_id

      find_record record_key if record_key&.any?
    end

    def find_record(key=record_key())
      InOrder::Aux::PolyFind.new(*key).call
    end

    def record_key(record_params)
      [ record_params[:type], params[:id] ].compact
    end

    def find_records(keys=record_keys())
      InOrder::Aux::PolyFind.call keys
    end

    def partial_name
      params[:partial_name] or params[:partial] or 'index'
    end
  end
end

