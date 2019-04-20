class AddTwitchColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.text :twitch_username, index: true, unique: true
      t.text :currently_streaming_on
    end
  end
end
