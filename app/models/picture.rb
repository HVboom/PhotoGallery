class Picture < ActiveRecord::Base
  # model extension
  mount_uploader :image, ImageUploader

  # relations
  belongs_to :gallery, :inverse_of => :pictures
  acts_as_list :scope => :gallery

  # validations
  before_validation :default_title
  before_validation :strip_whitespaces

  validates_presence_of :title
  validates_uniqueness_of :title, :case_sensitive => false
  validates_presence_of :gallery

  # copy to public directory
  after_save :publish

  # class methods
  def self.asciify_map
    map ||= Asciify::Mapping[:default]
  end

  def self.deploy
    # remove old files
    external_dir = File.join([Rails.public_path, ActiveModel::Naming.plural(self)].compact)
    FileUtils.rm_rf(Dir[File.join([external_dir, '[^.]*'])])

    # copy current files
    self.all.each do |picture|
      picture.copy_to
    end
  end

  # instance methods
  def export_filename
    ([self.gallery.name, "%02d" % self.position].join(' ').titleize.gsub(/\s+/, '_') + '.jpg').asciify(Picture.asciify_map) unless self.title.blank?
  end

  def external_url(version)
    unless self.title.blank? then
      File.join('', [ActiveModel::Naming.plural(self.class), version.to_s, self.export_filename].compact)
    end
  end

  def copy_to
    unless self.title.blank? then
      # copy orginal
      external_filename = File.join([Rails.public_path, self.external_url(nil)].compact)
      self.image.file.copy_to(external_filename)

      # copy all versions
      # self.image.versions.keys.each do |version|
      [:normal, :thumb].each do |version|
        external_filename = File.join([Rails.public_path, self.external_url(version)].compact)
        self.image.versions[version].file.copy_to(external_filename)
      end
    end
  end

  private
    def default_title
      self.title ||= File.basename(image.filename, '.*').titleize if image
    end

    def strip_whitespaces
      self.title.strip! unless self.title.blank?
    end

    def publish
      Rails.logger.debug "Picture - Changed attributes #{self.changes.inspect}"

      Gallery.find(self.gallery_id_was).copy_to if self.gallery_id_changed? and self.gallery_id_was
      unless self.gallery.blank? then
        self.gallery.copy_to if self.position_changed? or self.gallery_id_changed? or self.image_changed?
      end
    end
end
