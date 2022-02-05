class CreateWeathers < ActiveRecord::Migration[5.2]
  def change
    create_table :weathers do |t|
      t.decimal :temp_c, precision: 5, scale: 2
      t.decimal :temp_f, precision: 5, scale: 2
      t.string :region
      t.string :country
      t.string :weather_type
      t.integer :jogging_id, null: false

      t.timestamps
    end

    add_foreign_key :weathers, :joggings, column: :jogging_id
    add_index :weathers, :jogging_id, :unique => true
  end
end
