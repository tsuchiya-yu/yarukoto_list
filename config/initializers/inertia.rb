require "digest"

InertiaRails.configure do |config|
  config.version = lambda do
    Rails.cache.fetch("inertia-version", expires_in: 1.minute) do
      files = Dir[Rails.root.join("package.json")] + Dir[Rails.root.join("app/frontend/**/*")]
      Digest::SHA256.hexdigest(files.flat_map { |path| [path, File.mtime(path).to_i] }.join)
    end
  end

  config.ssr_enabled = ActiveModel::Type::Boolean.new.cast(
    ENV.fetch("INERTIA_SSR_ENABLED", "true")
  )
  config.ssr_url = ENV.fetch("INERTIA_SSR_URL", "http://ssr:13714")
end
