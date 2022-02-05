class CreateJoggings < ActiveRecord::Migration[5.2]
  def change
    create_table :joggings do |t|
      t.date :date, null: false
      t.time :duration, null: false
      t.integer :distance, null: false
      t.integer :seconds
      t.decimal :lon, precision: 10, scale: 6
      t.decimal :lat, precision: 10, scale: 6
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
