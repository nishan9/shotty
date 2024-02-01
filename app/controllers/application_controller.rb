require "selenium-webdriver"
require 'fileutils'
require 'nokogiri'
require 'net/http'
require 'uri'

class ApplicationController < ActionController::API

    def test 
        domain = params[:url]
        list_of_pages = extract_urls(domain)
        list_of_resolutions = get_resolutions(params[:devices].split(","))
        list_of_browsers = params[:browsers].split(",")
        
        parser(domain, list_of_pages[0..1], list_of_browsers, list_of_resolutions)
    end

    def parser(domain, list_of_pages, list_of_browsers, list_of_resolutions) 
        list_of_pages.each do | page |
            list_of_browsers.each do | browser |
                list_of_resolutions.each do | resolution |
                    selenium(domain, page, browser, resolution)
                end
            end
        end
    end

    def selenium(domain, page, browser, resolution)
        current_time = Time.now.strftime("%d-%m-%Y").to_s
        arr = page.split("/")
        filename = arr[arr.size - 1] + ".png"
        website_name = arr[2]
        directory = ""
        arr.each_with_index do |item, index |
            if index > 2 && index < arr.size - 1
                directory += item + "/"
            end
        end

        if browser == "chrome"
            driver = Selenium::WebDriver.for :chrome
            driver.manage.window.resize_to(resolution[0], resolution[1])
            driver.navigate.to page
            driver.save_screenshot("./#{filename}")
            driver.quit
        end

        Aws.config.update({
            region: 'eu-west-1',
            credentials: Aws::Credentials.new('AKIAQFID3FIP6UI6DCNJ', '')
        })

        s3_client = Aws::S3::Client.new(region: 'eu-west-1')


        File.open("./#{filename}", 'rb') do |file|
            s3_client.put_object(bucket: 'sky-protect-2', key: "#{website_name}/#{current_time}/#{directory}#{filename}", body: file)
        end
        
    end


    def extract_urls(domain)
        website_link = domain + "/sitemap.xml"
        doc = Nokogiri::XML(Net::HTTP.get(URI.parse(website_link)))

        pages = []
        doc.xpath('//xmlns:url').each do |url|
            pages.push(url.at_xpath('xmlns:loc').text)
        end
        return pages
    end

    def get_resolutions(deviceslist)
        device_arr = JSON.load (File.open "./screens.json")

        list_of_resolutions = []
        device_arr.each_with_index do |item, index |
            deviceslist.each do | device |
                if item["device"] == device
                    new_size = [item["width"], item["height"]]
                    list_of_resolutions.push(new_size)
                end
            end
        end
        return list_of_resolutions
    end

end
