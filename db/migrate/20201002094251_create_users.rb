class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string   :email, limit: 250, null: false
      t.string   :full_name, limit: 250
      t.integer  :role, null: false
      t.boolean  :active,  null: false, default: false

      t.string   :crypted_password, limit: 255
      t.string   :salt, limit: 255

      t.string   :reset_password_token,  :default => nil
      t.datetime :reset_password_email_sent_at,  :default => nil
      t.datetime :reset_password_token_expires_at,  :default => nil

      t.timestamps
    end

    add_index :users, :email, unique: true, where: "(active IS true)"
  end
end
