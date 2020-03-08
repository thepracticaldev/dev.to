module Search
  class ArticleSerializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :approved, :body_text, :class_name, :cloudinary_video_url,
               :comments_count, :experience_level_rating, :experience_level_rating_distribution,
               :featured, :featured_number, :hotness_score, :language,
               :main_image, :path, :positive_reactions_count, :published,
               :published_at, :reactions_count, :reading_time, :score, :title

    # video_duration_in_minutes in Elasticsearch is mapped as an integer
    # however, it really is a string in the format 00:00 which is why we
    # added an extra field to handle that string
    attribute :video_duration_string, &:video_duration_in_minutes
    attribute :video_duration_in_minutes, &:video_duration_in_minutes_integer

    attribute :flare_tag do |article|
      article.flare_tag.to_json
    end

    attribute :tags do |article|
      article.tags.map do |tag|
        { name: tag.name, keywords_for_search: tag.keywords_for_search }
      end
    end

    attribute :user do |article|
      NestedUserSerializer.new(article.user).serializable_hash.dig(
        :data, :attributes
      )
    end

    attribute :organization, if: proc { |a| a.organization.present? } do |article|
      {
        slug: article.organization.slug,
        name: article.organization.name,
        id: article.organization.id,
        profile_image_90: article.organization.profile_image_90
      }
    end
  end
end
