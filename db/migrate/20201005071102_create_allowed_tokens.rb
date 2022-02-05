class CreateAllowedTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :allowed_tokens do |t|

      t.string :encrypted_token, null: false
      t.integer :user_id, limit: 8, null: false
      t.string :ip, limit: 150
      t.string :os, limit: 250
      t.string :user_agent, limit: 250
      t.string :platform, limit: 250
      t.string :browser, limit: 250
      t.datetime :expired_at, null: false

      t.timestamps
    end

    add_index :allowed_tokens, :encrypted_token, unique: true

  end
end
