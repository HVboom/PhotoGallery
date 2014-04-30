class Gallery < ActiveRecord::Base
  # relations
  # has_many :pictures, :order => 'position', :inverse_of => :gallery
  has_many :pictures, :inverse_of => :gallery # , -> { order("position ASC") }

  # mass assignment
  accepts_nested_attributes_for :pictures

  # callback to copy pictures to the public location
  after_save :publish

  # validations
  before_validation :strip_whitespaces

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  def copy_to
    #ActsAsList.reorder_positions!(self.pictures)
    self.pictures.each do |picture|
      picture.copy_to
    end
  end

  private
    def strip_whitespaces
      self.name.strip! unless self.name.blank?
    end

    def publish
      Rails.logger.debug "Gallery - Changed attributes #{self.changes.inspect}"

      self.copy_to # if !self.page.blank? and self.page_id_changed?
    end
end
