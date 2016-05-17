require 'nuvi/unzipper'
require 'nuvi/zip_downloader'
require 'nuvi/zip_index'

require 'logger'
require 'redis'

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

    xmls = Dir[File.join(xml_files_directory, '*.xml')]

    new_items = 0
    xmls.each do |xml_file|
      if process_xml(xml_file)
        new_items += 1
      end
    end

    logger.info("Added #{new_items} new items to the NEWS_XML list")

    # Cleanup the zip files
    FileUtils.rm_rf(xml_files_directory)

    # Do not delete the zip file.
    # Since the software has to be run multiple times, and the zip files are
    # quite large, it is nice to have a local cache.
    # The ZipDownloader class does nothing when the zip file is already there.
    #File.delete(zip_file)
  end

  # How it works:
  #   The NEWS_XML redis list contains all the XML file contents processed
  #   without duplicates.
  #   To avoid duplicates we mantain a redis set of the file hashes. If the
  #   hash is not in the set, it is added and the file content is added to
  #   the NEWS_XML list.
  #
  #   Returns true if the news item is a new entry
  def process_xml(xml_file)
    hash = File.basename(xml_file, '.xml')

    # sadd returns true if the element was not in the set
    if redis.sadd('NEWS_HASHES', hash)
      content = File.read(xml_file)
      redis.rpush('NEWS_XML', content)
      true
    end
  end

  def redis
    @redis ||= Redis.new(host: redis_host, port: redis_port)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def downloader
    @downloader ||= ZipDownloader.new
  end

  attr_writer :redis_host, :redis_port

  def redis_host
    @redis_host ||= 'localhost'
  end

  def redis_port
    @redis_port ||= 6379
  end
end
