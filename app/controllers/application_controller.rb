require "selenium-webdriver"
require 'fileutils'
require 'nokogiri'
require 'net/http'
require 'uri'
# require_relative './extract_url_service'
# require_relative './s3_bucket_file_explorer'

class ApplicationController < ActionController::API

    def test 
        # extract_url_service = ExtractURLService.new
        # list_of_pages = extract_url_service.extract_urls(params[:url])
        # list_of_resolutions = get_resolutions(params[:devices].split(","))
        # list_of_browsers = params[:browsers].split(",")
        
        # parser(params[:url], list_of_pages, list_of_browsers, list_of_resolutions)
        render status: :ok
    end


    def directory 
        fileExplorer = S3BucketFileExplorer.new()
        folders = fileExplorer.root_folder(params[:prefix])
        render json: folders , status: :ok
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
        url_arr = page.split("/")
        filename = url_arr[url_arr.size - 1] + ".png"
        website_name = url_arr[2]
        directory = ""
        url_arr.each_with_index do |item, index |
            if index > 2 && index < url_arr.size - 1
                directory += item + "/"
            end
        end

        if browser == "chrome"
            driver = Selenium::WebDriver.for :chrome
        # elsif browser == "firefox"
        #     driver = Selenium::WebDriver.for :firefox
        end
        
        driver.manage.window.resize_to(resolution[0], resolution[1])
        driver.navigate.to page
        driver.save_screenshot("./#{filename}")
        driver.quit

        Aws.config.update({
            region: 'eu-west-1',
            credentials: Aws::Credentials.new(ENV['aws_key'], ENV['aws_secret'])
        })

        s3_client = Aws::S3::Client.new(region: 'eu-west-1')


        File.open("./#{filename}", 'rb') do |file|
            s3_client.put_object(bucket: 'sky-protect-2', key: "#{website_name}/#{current_time}/#{directory}#{get_device(resolution[0],resolution[1])}/#{filename}", body: file)
        end
        File.delete("./#{filename}")
    end

    private

    def get_resolutions(deviceslist)
        device_url_arr = JSON.load (File.open "./screens.json")

        list_of_resolutions = []
        device_url_arr.each do |item |
            deviceslist.each do | device |
                if item["device"] == device
                    new_size = [item["width"], item["height"]]
                    list_of_resolutions.push(new_size)
                end
            end
        end
        return list_of_resolutions
    end

    def get_device(width, height)
        device_url_arr = JSON.load (File.open "./screens.json")
        device_url_arr.each do | item | 
            if item["width"] == width && item["height"] == height
                return item["device"]
            end
        end
    end

end
