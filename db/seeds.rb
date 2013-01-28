# msgs = Message.where('messages.created_at < ?', 1.week.ago)
# msgs.update_all(read_on: Time.now)

User.find_each do |u|
  User.reset_counters u.id, :entries
  User.reset_counters u.id, :bids
end

CarBrand.find_each do |cb|
  CarBrand.reset_counters cb.id, :car_models
end

CarModel.find_each do |cm|
  CarModel.reset_counters cm.id, :car_variants
  CarModel.reset_counters cm.id, :entries
end

CarVariant.find_each do |cm|
  CarVariant.reset_counters cm.id, :entries
end
