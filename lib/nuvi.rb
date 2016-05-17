require 'nuvi/unzipper'
require 'nuvi/zip_downloader'
require 'nuvi/zip_index'
require 'logger'

module Nuvi
  extend self

  def start(base_url)
    index = ZipIndex.new(base_url)
    zip_urls = index.zip_urls
    logger.debug("Found #{zip_urls.count} zip files")

    zip_urls.each { |zip| process(zip) }
  end

  def process(zip)
    zip_file = downloader.download(zip)
    xml_files_directory = Unzipper.new.unzip(zip_file)

    # Cleanup the zip files
    FileUtils.rm_rf(xml_files_directory)

    # Do not delete the zip file.
    # Since the software has to be run multiple times, and the zip files are
    # quite large, it is nice to have a local cache.
    # The ZipDownloader class does nothing when the zip file is already there.
    #File.delete(zip_file)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def downloader
    @downloader ||= ZipDownloader.new
  end
end
