class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :title
      t.string :image
      t.integer :position
      t.references :gallery, index: true

      t.timestamps
    end
  end
end
