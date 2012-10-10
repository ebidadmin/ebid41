class CreateCarOrigins < ActiveRecord::Migration
  def change
    create_table :car_origins do |t|
      t.string :name
    end
  end
end
