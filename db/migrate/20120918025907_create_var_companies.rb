class CreateVarCompanies < ActiveRecord::Migration
  def change
    create_table :var_companies do |t|
      t.string :name
      t.integer :creator_id
      t.timestamps
    end
    add_index :var_companies, :creator_id
  end
end
