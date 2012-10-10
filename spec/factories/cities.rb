# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city do
    name "MyString"
    region_id 1
    creator_id 1
  end
end
