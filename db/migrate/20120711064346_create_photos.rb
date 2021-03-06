class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :entry_id
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
      t.boolean :photo_processing,        default: 1
      t.timestamps
    end
    add_index :photos, :entry_id
  end
end
