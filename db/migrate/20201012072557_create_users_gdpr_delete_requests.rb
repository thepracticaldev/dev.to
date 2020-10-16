class CreateUsersGdprDeleteRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :users_gdpr_delete_requests do |t|
      t.integer :user_id
      t.string :email
      t.string :username

      t.timestamps
    end
  end
end
