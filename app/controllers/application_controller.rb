require "selenium-webdriver"
require 'nokogiri'
require 'net/http'
require 'uri'
require 'fileutils'

class ApplicationController < ActionController::API
    def test 
        # Capturing screenshots
        # puts "Called Endpoint"
  
        

        # @doc = Nokogiri::XML(xml_str)

        # puts @doc.xpath("//url")

        doc = Nokogiri::XML(Net::HTTP.get(URI.parse('https://screenshotone.com/sitemap.xml')))

        pages = []
        doc.xpath('//xmlns:url').each do |url|
            pages.push(url.at_xpath('xmlns:loc').text)
        end

        pages.each_with_index do | item, index |
            selenium(item)
            if index > 2
                break
            end
        end

    end

    def selenium(url)
        directory_name = Time.now.strftime("%d-%m-%Y").to_s
        if !Dir.exist?(directory_name)
            FileUtils.mkdir_p directory_name
        end

        driver = Selenium::WebDriver.for :chrome
        driver.navigate.to url
        url = url.delete("/")
        driver.save_screenshot("./#{directory_name}/#{url}.png")
        driver.quit
        # ##{url}/#{Time.now}/#{third_folder}/
    end
end
