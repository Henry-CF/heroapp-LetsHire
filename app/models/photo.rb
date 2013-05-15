require 'file_access'

class Photo < ActiveRecord::Base
  attr_accessible :interview, :interview_id, :photo_name, :description, :photo_path

  belongs_to :interview, :foreign_key => 'interview_id'

  validates :interview_id, :photo_path, :presence => true

  #NOTE: For these methods inherits from ActiveRecord, we prefix the
  #function call with 'self', for these our defined functions we call
  #them directly.

  def savefile(filename, fileio)
    self.class.transaction do
      self.photo_name = filename
      self.photo_path = format(upload(fileio))
      self.save
    end
  end

  def readfile(fileio)
    self.class.transaction do
      download(fileio)
    end
  end

  def updatefile(filename, fileio)
    self.class.transaction do
      clean
      self.photo_name = filename
      self.photo_path = format(upload(fileio))
      self.update_attributes({:photo_name => self.photo_name,
                              :photo_path => self.photo_path})
    end
  end

  def deletefile
    self.class.transaction do
      clean
    end
  end

  def upload(file)
    path = nil
    do_upload do |uploader|
      path = uploader.upload(file)
    end
    path
  end

  def download(file)
    do_download do |downloader|
      downloader.download(file, unformat(self.photo_path))
    end
  end

  def clean
    do_clean do |cleaner|
      cleaner.clean(unformat(self.photo_path))
    end
  end

private

  def format(photo_path)
    photo_path.to_s
  end

  def unformat(photo_path)
    photo_path.to_i
  end

  #NOTE: Currently each time we finish file upload/download we free io
  #resource, we do not want to take over too many connections.

  def do_upload(&blk)
    uploader = FileUploader.new
    blk.call(uploader)
    uploader.close
  end

  def do_download(&blk)
    downloader = FileDownloader.new
    blk.call(downloader)
    downloader.close
  end

  def do_clean(&blk)
    cleaner = FileCleaner.new
    blk.call(cleaner)
    cleaner.close
  end

end
