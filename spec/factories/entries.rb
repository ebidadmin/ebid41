# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do
    user_id 1
    company_id 1
    ref_no "MyString"
    year_model 1
    car_brand_id 1
    car_model_id 1
    car_variant_id 1
    plate_no "MyString"
    serial_no "MyString"
    motor_no "MyString"
    date_of_loss "2012-07-11"
    city_id 1
    term_id 1
    line_items_count 1
    photos_count 1
    status "MyString"
    online "2012-07-11 12:01:28"
    bid_until "2012-07-11"
    bids_count 1
    decided "2012-07-11 12:01:28"
    relisted "2012-07-11 12:01:28"
    relist_count 1
    redecided "2012-07-11 12:01:28"
    expired "2012-07-11"
    chargeable_expiry false
    orders_count 1
  end
end
