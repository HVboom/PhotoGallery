json.array!(@pictures) do |picture|
  json.extract! picture, :id, :title, :image, :position, :gallery_id
  json.url picture_url(picture, format: :json)
end
