module Api::V1::Policies::Relationships
  class PoolController < Api::V1::BaseController
    before_action :scope_by_subdomain!
    before_action :authenticate_with_token!
    before_action :set_policy, only: [:create, :destroy]
    before_action :set_license, only: [:destroy]

    # POST /policies/1/relationships/pool
    def create
      authorize @policy
      @license = license_params.to_h

      if @policy.pool.include? @license
        render status: :conflict
      else
        @policy.pool_push << @license

        render status: :created
      end
    end

    # DELETE /policies/1/relationships/pool/2
    def destroy
      authorize @policy

      if @policy.pool.include? @license
        key = @policy.pool_delete @license

        render_meta key: key
      else
        render_not_found
      end
    end

    private

    def set_policy
      @policy = @current_account.policies.find_by_hashid params[:policy_id]
      @policy || render_not_found
    end

    def set_license
      @license = params[:id]
    end

    def license_params
      params.require(:license).permit :key
    end
  end
end
