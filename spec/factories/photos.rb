# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    entry_id 1
    photo_file_name "MyString"
    photo_content_type "MyString"
    photo_file_size 1
    photo_updated_at "2012-07-11 14:43:47"
    photo_processing false
  end
end
