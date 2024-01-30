require "selenium-webdriver"
require 'nokogiri'
require 'net/http'
require 'uri'

class ApplicationController < ActionController::API
    def test 
        # Capturing screenshots
        # puts "Called Endpoint"
        # driver = Selenium::WebDriver.for :chrome
        # driver.navigate.to "https://screenshotone.com"
        # driver.save_screenshot("./screenshotone.png")
        # driver.quit
        

        # @doc = Nokogiri::XML(xml_str)

        # puts @doc.xpath("//url")

        doc = Nokogiri::XML(Net::HTTP.get(URI.parse('https://screenshotone.com/sitemap.xml')))

        pages = []
        doc.xpath('//xmlns:url').each do |url|
          pages.push(url.at_xpath('xmlns:loc').text)
        end
        p pages.size
        #parsed_data = Nokogiri::HTML.parse()
        #puts parsed_data

    end
end
