module Public
  class BaseController < ApplicationController
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

    def fixed_notice_text
      <<~TEXT.strip
        ※本サービスで提供されるやることリストは、一般的な情報をもとにした参考例です。
        手続きの要否や内容は、契約内容・地域・個別状況によって異なる場合があります。
        必ず公式サイトや契約書などの一次情報もあわせてご確認ください。
      TEXT
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
