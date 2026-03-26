class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :category, null: false, default: 0
      t.string :platform
      t.text :notes
      t.string :cover_image_url
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :items, [ :user_id, :status ]
    add_index :items, [ :user_id, :category ]
  end
end
