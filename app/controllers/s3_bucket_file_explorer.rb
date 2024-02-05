class S3BucketFileExplorer
    def root_folder(prefix)
        Aws.config.update({
            region: 'eu-west-1',
            credentials: Aws::Credentials.new(ENV['aws_key'], ENV['aws_secret'])
        })

        s3_client = Aws::S3::Client.new(region: 'eu-west-1')
        directories =  s3_client.list_objects(bucket: 'sky-protect-2', delimiter: "/", prefix: prefix)
        # prefix on every element to get folder names
        folders = directories.common_prefixes.map(&:prefix)
        if folders.empty? 
            content_arr = s3_client.list_objects_v2(bucket: 'sky-protect-2', prefix: prefix).contents.map{ |element| "https://sky-protect-2.s3.eu-west-1.amazonaws.com/" + element.key}
        else 
            folders
        end
    end
end