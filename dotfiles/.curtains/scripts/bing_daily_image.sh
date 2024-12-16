#$!/bin/bash

while getopts ":o:" option; do
  case $option in
    o)  targetDir="${OPTARG}"
        ;;
    :)  echo "Option -${OPTARG} requires an argument."
        exit 1;;
    ?)  echo "Invalid option: -${OPTARG}." 
        exit 1
        ;;
  esac
done

if [ -z "$targetDir" ]; then
  echo "Usage: $0 -o <output directory>"
  exit 1
fi

bingUrl="https://www.bing.com"
jsonUrl="${bingUrl}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"

mkdir -p $targetDir

json_data=$(curl -s $jsonUrl)

imageUrlParams=$(echo $json_data | grep -oP '(?<="url":")[^"]*') 
imageUrl="${bingUrl}${imageUrlParams}&rf=LaDigue_UHD.jpg"

title=$(echo $json_data | grep -oP '(?<="title":")[^"]*')
location=$(echo $json_data | grep -oP '(?<="copyright":")[^,]*' | sed 's/^[^()]* (\([^)]*\)).*$/\1/')

fileName="${title// /_}_${location// /_}.jpg"
filePath="$targetDir/$fileName"

if [ ! -f "$filePath" ]; then
  curl -so "${filePath}" $imageUrl
  echo "Image of the Day downloaded as ${filePath}"
fi