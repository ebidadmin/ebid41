Paperclip.interpolates :hash_path do |attachment, style|
  # set the FINAL_POST_ID_BEFORE_MD5_HASH to be the ID of the existing latest attachment at the time of transition.
  return "#{attachment.instance.id}" if attachment.instance.id < 34172

  hash = Digest::MD5.hexdigest(attachment.instance.id.to_s + 'secret')
  hash_path = ''
 
  3.times { hash_path += '/' + hash.slice!(0..2) }
  hash_path[1..12] << ''
end