#~ ENV['MERCHANT_ID'] = '433svmg3vhmkk6jg'
#~ ENV['PUBLIC_KEY'] = 'fw75w9ks7pvrf6sn'
#~ ENV['PRIVATE_KEY'] = 'cfd2773b14b03d587dabc42ec2bc4224'
#~ ENV['CLIENT_SIDE_ENCRYPTION_KEY'] = 'MIIBCgKCAQEAx97zgH+kjhnV9y1pPGRt3ogNYGB4VpDeTr/JoY6tQEo3xs7jUE2lyoZ'

FogStorage = Fog::Storage.new(
  provider: "Google",
  google_storage_access_key_id:     "GOOG2OW3YZW4RKJG7V44",
  google_storage_secret_access_key: "b7RYAtC+NkKYbU6yGKLEpnvjEBGnhfCXrrH7MwjC"
)

StorageBucket = FogStorage.directories.new key: "byte_contest"
