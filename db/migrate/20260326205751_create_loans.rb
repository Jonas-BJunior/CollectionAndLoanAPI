class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: true
      t.date :loan_date, null: false
      t.date :expected_return_date
      t.datetime :returned_at

      t.timestamps
    end

    add_index :loans, [ :item_id, :returned_at ]
    add_index :loans, [ :friend_id, :returned_at ]
    add_index :loans, [ :user_id, :returned_at ]
  end
end
