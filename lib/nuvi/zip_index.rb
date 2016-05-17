require 'open-uri'
require 'nokogiri'

module Nuvi
  class ZipIndex
    attr_accessor :url

    def initialize(url)
      self.url = url
    end

    def zip_urls
      # Open the index
      # Parse the html
      # Select all the links inside table cells
      # Skip the first entry ("Parent Directory")
      # Take the link targets, adding the base url
      @urls ||= Nokogiri::HTML(open(url).read).css('td a')[1..-1].map { |a| url + a[:href] }
    end
  end
end
