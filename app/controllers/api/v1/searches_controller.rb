module Api::V1
  class SearchesController < Api::V1::BaseController
    MINIMUM_SEARCH_QUERY_SIZE = 3

    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!

    # POST /search
    def search
      query, type = search_params[:meta].fetch_values 'query', 'type'
      model = type.classify.constantize rescue nil

      if !model.respond_to?(:search) || !current_account.respond_to?(type.pluralize)
        return render_bad_request(
          detail: "unsupported search type '#{type.camelize(:lower)}'",
          source: { pointer: "/meta/type" }
        )
      end

      authorize model

      json = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
        search_attrs = model::SEARCH_ATTRIBUTES.map { |a| a.is_a?(Hash) ? a.keys.first : a }
        search_rels = model::SEARCH_RELATIONSHIPS
        options = {
          expose: { url_helpers: Rails.application.routes.url_helpers },
          class: {
            Account: SerializableAccount,
            Token: SerializableToken,
            Product: SerializableProduct,
            Policy: SerializablePolicy,
            User: SerializableUser,
            License: SerializableLicense,
            Machine: SerializableMachine,
            Key: SerializableKey,
            Billing: SerializableBilling,
            Plan: SerializablePlan,
            WebhookEndpoint: SerializableWebhookEndpoint,
            WebhookEvent: SerializableWebhookEvent,
            Metric: SerializableMetric,
            Error: SerializableError
          }
        }

        res = current_account.send type.pluralize

        query.each do |attribute, value|
          if !res.respond_to?("search_#{attribute}") || (!search_attrs.include?(attribute.to_sym) &&
            !search_rels.key?(attribute.to_sym))
            return render_bad_request(
              detail: "unsupported search query '#{attribute.camelize(:lower)}' for resource type '#{type.camelize(:lower)}'",
              source: { pointer: "/meta/query/#{attribute.camelize(:lower)}" }
            )
          end

          case attribute.to_sym
          when :metadata
            if !value.is_a?(Hash)
              return render_bad_request(
                detail: "search query for 'metadata' must be a hash of key-value search terms",
                source: { pointer: "/meta/query/metadata" }
              )
            end

            # Transform our metadata query into a query with snakecased keys
            value.each do |k, v|
              if v.is_a?(String) && v.size < MINIMUM_SEARCH_QUERY_SIZE
                return render_bad_request(
                  detail: "search query for '#{k.camelize(:lower)}' is too small (minimum #{MINIMUM_SEARCH_QUERY_SIZE} characters)",
                  source: { pointer: "/meta/query/metadata/#{k.camelize(:lower)}" }
                )
              end

              res = res.search_metadata "#{k.underscore}:#{v}"
            end
          else
            if value.is_a?(String) && value.size < MINIMUM_SEARCH_QUERY_SIZE
              return render_bad_request(
                detail: "search query for '#{attribute.camelize(:lower)}' is too small (minimum #{MINIMUM_SEARCH_QUERY_SIZE} characters)",
                source: { pointer: "/meta/query/#{attribute.camelize(:lower)}" }
              )
            end

            res = res.send "search_#{attribute}", value.to_s
          end
        end

        res = policy_scope apply_scopes(res)

        JSONAPI::Serializable::Renderer.new.render(res, options)
      end

      render json: json
    end

    private

    def cache_key
      query, type = search_params[:meta].fetch_values 'query', 'type'

      [:searches, current_account.id, type, Base64.strict_encode64(query.to_json), request.query_string.parameterize].select(&:present?).join ":"
    end

    typed_parameters do
      options strict: true

      on :search do
        param :meta, type: :hash do
          param :type, type: :string
          param :query, type: :hash, allow_non_scalars: true
        end
      end
    end
  end
end
