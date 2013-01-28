class AddCounterCacheToVehicles < ActiveRecord::Migration
  def change
    add_column :car_brands, :car_models_count, :integer
    add_column :car_models, :car_variants_count, :integer
    add_column :car_models, :entries_count, :integer
    add_column :car_variants, :entries_count, :integer
  end
end