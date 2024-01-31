require "selenium-webdriver"
require 'nokogiri'
require 'net/http'
require 'uri'
require 'fileutils'

class ApplicationController < ActionController::API


    def test 
        parser(params[:url], params[:browsers].split(","), params[:devices].split(","))
    end


    def parser(domain, browserlist, deviceslist)

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

        website_link = domain + "/sitemap.xml"
        doc = Nokogiri::XML(Net::HTTP.get(URI.parse(website_link)))

        pages = []
        doc.xpath('//xmlns:url').each do |url|
            pages.push(url.at_xpath('xmlns:loc').text)
        end
        
        pages.each_with_index do | item, index |
            if index > 0
                break
            end
            makedirs(item, browserlist, list_of_resolutions)
        end
    end



    def makedirs(url, browsers, list_of_resolutions)
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
        

        browsers.each do | browser |
            single_dir = domain + "/" + browser + "/" + current_time + "/" + name
            FileUtils.mkdir_p single_dir unless Dir.exist?(single_dir)
            selenium(url, single_dir, filename, browser, list_of_resolutions)
        end
    end


    def selenium(url, newdir, filename, browser, screens)
        screens.each_with_index do | item, index |
            if browser == "chrome"
                driver = Selenium::WebDriver.for :chrome
                driver.manage.window.resize_to(item[0], item[1])
                driver.navigate.to url
                driver.save_screenshot("./#{newdir}/#{filename}")
                driver.quit
            end
            p browser
            if browser == "firefox"
                p "executed"
                driver = Selenium::WebDriver.for :firefox
                driver.manage.window.resize_to(item[0], item[1])
                driver.navigate.to url
                driver.save_screenshot("./#{newdir}/#{filename}")
                driver.quit
            end

        end
    end

end
