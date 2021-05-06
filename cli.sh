#!/bin/bash


# Create Blob storage container
$blobStorageAccount"summercampblobphoto"
$blobStorageAccountKey=$(az storage account keys list -g summercampfriends-rg \
  -n summercampblobphoto --query "[0].value" --output tsv)
echo $blobStorageAccountKey 
# az storage container create -n images --account-name summercampblobphoto \
#   --account-key SazEu9ztDjbW6Os2xkvY1eRUwxT1xgtgR4xaqUkk0POJx27CGjBCRuQZOvhfDgqOipdQkpBYmpvnrI38UW/p8Q== --public-access off

# az storage container create -n thumbnails --account-name $blobStorageAccount \
#   --account-key $blobStorageAccountKey --public-access container

# echo "Make a note of your Blob storage account key..."
# echo $blobStorageAccountKey