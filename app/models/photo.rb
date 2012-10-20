class Photo < ActiveRecord::Base
  attr_accessible :entry_id, :photo_content_type, :photo_file_name, :photo_file_size, 
  :photo_processing, :photo_updated_at, :photo

  belongs_to :entry, counter_cache: true
  has_attached_file :photo, styles: { tiny: ["80x60#", :jpg], thumb: ["222x142#", :jpg], large: ["640x480>", :jpg] },
        :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
        :url => "/system/:attachment/:id/:style/:filename"
        
  # validates_attachment_presence :photo, message: "You must upload at least 2 photos."
  # validates_attachment_content_type :photo, 
  # :content_type => ['image/jpeg', 'image/pjpeg', 'image/JPG',
  #                                  'image/jpg', 'image/png'], message: "Acceptable photo formats are jpg, jpeg, or png."

   include Rails.application.routes.url_helpers

   def to_jq_upload
     {
       "name" => read_attribute(:photo_file_name),
       "size" => read_attribute(:photo_file_size),
       "url" => photo.url(:large),
       "thumbnail_url" => photo.url(:tiny),
       "delete_url" => photo_path(self),
       "delete_type" => "DELETE",
       "entry_id" => read_attribute(:entry_id)
     }
   end
  
end
