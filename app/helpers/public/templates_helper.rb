module Public
  module TemplatesHelper
    include ActionView::Helpers::TextHelper

    def public_list_meta_description(sort:, keyword:, sort_options:, default_sort:)
      sort_label = sort_options.fetch(sort, sort_options[default_sort])
      base = "引越しのやることリストを#{sort_label}で並べ替えて確認できます。"
      if keyword.present?
        %(#{base} キーワード「#{keyword}」に合致するリストだけを表示中です。)
      else
        %(#{base} 気になるリストを開いて詳細とレビューをチェックできます。)
      end
    end

    def public_template_meta_description(template)
      truncate(template.description, length: 120)
    end
  end
end
