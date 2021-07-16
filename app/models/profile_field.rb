class ProfileField < ApplicationRecord
  include ActsAsProfileField

  HEADER_FIELD_LIMIT = 3
  HEADER_LIMIT_MESSAGE = "maximum number of header fields (#{HEADER_FIELD_LIMIT}) exceeded".freeze

  # Key names follow the Rails form helpers
  enum input_type: {
    text_field: 0,
    text_area: 1,
    check_box: 2,
    color_field: 3
  }

  enum display_area: {
    header: 0,
    left_sidebar: 1,
    settings_only: 2
  }

  belongs_to :profile_field_group, optional: true

  validates :display_area, presence: true
  validates :input_type, presence: true
  validates :show_in_onboarding, inclusion: { in: [true, false] }
  validate :maximum_header_field_count

  def type
    return :boolean if check_box?

    :string
  end

  private

  def maximum_header_field_count
    return if self.class.header.count <= HEADER_FIELD_LIMIT

    errors.add(:display_area, HEADER_LIMIT_MESSAGE)
  end
end
