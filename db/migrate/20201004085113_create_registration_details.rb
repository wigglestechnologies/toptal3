class CreateRegistrationDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :registration_details do |t|
      t.string   :token, null: false,  limit: 255, index: true
      t.string   :email, null: false,  limit: 255, index: true
      t.datetime :valid_until, null: false

      t.timestamps
    end
  end
end
