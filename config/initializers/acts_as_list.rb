module ActsAsList
  # positions can get mixed up when users click like crazy -> reorder them if necessary
  # ActsAsList.reorder_positions!(current_user.categories)
  def self.reorder_positions!(objects)
    objects.each_with_index do |object, index|
      new_position = index + 1
      next if object.position == new_position
      object.update_attribute(:position, new_position)
    end
  end
end

