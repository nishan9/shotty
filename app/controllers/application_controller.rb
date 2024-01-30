require "selenium-webdriver"
require 'nokogiri'
require 'net/http'
require 'uri'
require 'fileutils'

class ApplicationController < ActionController::API

    def test 

        website_link = "https://screenshotone.com" + "/sitemap.xml"
        doc = Nokogiri::XML(Net::HTTP.get(URI.parse(website_link)))

        pages = []
        doc.xpath('//xmlns:url').each do |url|
            pages.push(url.at_xpath('xmlns:loc').text)
        end

        pages.each_with_index do | item, index |
            if index > 3
                break
            end
            selenium(item)
        end

    end

    def selenium(url)
        arr = url.split("/")
        domain = arr[2]
        filename = arr[arr.size - 1] + ".png"

        name = ""
        arr.each_with_index do |item, index |
            if index > 2 && index < arr.size - 1
                name += item + "/"
            end
        end

        current_time = Time.now.strftime("%d-%m-%Y").to_s

        newdir = domain + "/" + current_time + "/" + name


        
        FileUtils.mkdir_p newdir unless Dir.exist?(newdir)


        driver = Selenium::WebDriver.for :chrome
        driver.navigate.to url
        driver.save_screenshot("./#{newdir}/#{filename}")
        driver.quit









    end
end
