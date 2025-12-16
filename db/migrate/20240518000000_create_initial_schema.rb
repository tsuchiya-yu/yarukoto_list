class CreateInitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :templates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.text :author_notes

      t.timestamps
    end

    create_table :template_items do |t|
      t.references :template, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :template_items, %i[template_id position]

    create_table :template_reviews do |t|
      t.references :template, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end

    create_table :template_ratings do |t|
      t.references :template, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false

      t.timestamps
    end
    add_index :template_ratings, %i[template_id user_id], unique: true

    create_table :user_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :user_lists, %i[user_id position]

    create_table :user_list_items do |t|
      t.references :user_list, null: false, foreign_key: true
      t.references :template_item, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.boolean :completed, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :user_list_items, %i[user_list_id position]
  end
end
