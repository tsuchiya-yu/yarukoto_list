module Public
  class BaseController < ApplicationController
    skip_before_action :require_login

    private

    def template_summary(template)
      {
        id: template.id,
        title: template.title,
        description: template.description,
        author_name: template.user.name,
        updated_at: template.updated_at.iso8601,
        average_score: template.public_average_score,
        ratings_count: template.public_ratings_count,
        reviews_count: template.public_reviews_count,
        copies_count: template.public_copies_count
      }
    end

    def default_meta_tags(title:, description:)
      {
        title: title,
        description: description,
        og_title: "#{title} | やることリスト",
        og_description: description,
        og_image: default_og_image_path
      }
    end

    def default_og_image_path
      "/apple-touch-icon.png"
    end
  end
end
