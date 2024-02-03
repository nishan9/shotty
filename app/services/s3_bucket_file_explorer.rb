class S3BucketFileExplorer
    def root_folder
        Aws.config.update({
            region: 'eu-west-1',
            credentials: Aws::Credentials.new('AKIAQFID3FIP6UI6DCNJ', ENV['aws_secret'])
        })

        s3_client = Aws::S3::Client.new(region: 'eu-west-1')
        
        directories =  s3_client.list_objects(bucket: 'sky-protect-2', delimiter: '/')
        # prefix on every element to get folder names
        directories.common_prefixes.map(&:prefix)
    end
end