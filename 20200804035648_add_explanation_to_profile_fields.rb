class AddExplanationToProfileFields < ActiveRecord::Migration[6.0]
  def change
    add_column :profile_fields, :explanation, :string
  end
end
