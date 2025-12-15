require "uri"

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data, :blob
    policy.object_src :none
    policy.style_src :self, :https, :unsafe_inline

    script_src = [:self, :https]
    connect_src = [:self, :https]

    if Rails.env.development?
      origin = ENV.fetch("VITE_DEV_SERVER_ORIGIN", "http://localhost:5173")
      uri = URI(origin)
      ws_origin = origin.sub(/^http/i, "ws")

      script_src += [origin, :unsafe_eval]
      connect_src += [origin, ws_origin]

      if uri.host != "localhost"
        localhost_origin = "#{uri.scheme}://localhost:#{uri.port}"
        localhost_ws_origin = localhost_origin.sub(/^http/i, "ws")
        script_src << localhost_origin
        connect_src += [localhost_origin, localhost_ws_origin]
      end
    end

    policy.script_src(*script_src)
    policy.connect_src(*connect_src)

    # Generate session nonces for permitted importmap, inline scripts, and inline styles.
    config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
    config.content_security_policy_nonce_directives = %w[script-src]
  end
end
