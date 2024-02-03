class ExtractURLService
    def initialize(domain)
        @domain = domain
    end
    
    def extract_urls
        doc = Nokogiri::XML(Net::HTTP.get(URI.parse(@domain + "/sitemap.xml")))

        pages = []
        doc.xpath('//xmlns:url').each do |url|
            pages.push(url.at_xpath('xmlns:loc').text)
        end
        return pages
    end
end