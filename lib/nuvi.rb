require 'nuvi/zip_downloader'
require 'nuvi/zip_index'
require 'logger'

module Nuvi
  extend self

  def add_to_redis(base_url)
    index = ZipIndex.new(base_url)
    zip_urls = index.zip_urls
    logger.info("Found #{zip_urls.count} zip files")
    downloader = ZipDownloader.new

    zip_urls.each { |zip| downloader.download(zip) }
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
