json.type_of "organization"

json.extract!(
  @organization,
  :username,
  :name,
  :summary,
  :twitter_username,
  :github_username,
  :url,
  :location,
  :tech_stack,
  :tag_line,
  :story,
)

json.joined_at utc_iso_timestamp(@organization.created_at)
json.profile_image Images::Profile.call(@organization.profile_image_url, length: 640)
