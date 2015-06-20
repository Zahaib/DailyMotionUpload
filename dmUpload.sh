#!/bin/bash
[ "$#" -lt 6 ] && { echo "Usage: $(basename $0) video.mp4 -u=username -p=password -k=api_key -s=api_secret -c=category [ -t=\"title\" ] [ -l=language ] [ tag,another tag ]

If no title is specified, the filename (without extension) is used as title.
Default language is english (en)."; exit 1; }

while getopts :u:p:k:s:t:c:l: FLAG; do 
 case $FLAG in
  k)
   APIKEY="$OPTARG"
   ;;
  s)
   APISECRET="$OPTARG"
   ;;
  u)
   USERNAME="$OPTARG"
   ;;
  p)
   PASSWORD="$OPTARG"
   ;;
  t)
   TITLE="$OPTARG"
   ;;
  c)
   CATEGORY="$OPTARG"
   ;;
  l)
   LANGUAGE="$OPTARG"
   ;;
 esac
done
shift $((OPTIND-1))

SCOPE="read+write"
FILE="$1"
[ "$TITLE" = "" ] && TITLE="$(basename $1)" && TITLE="${TITLE%.*}"

[ "$LANGUAGE" = "" ] && LANGUAGE=en
shift
TAGS="$*"

#TITLE=$(basename "$FILE")
#TITLE="${TITLE%.*}" #<--- Same title as file's name

lineclear() { echo -en "\r\033[K"; }


#declare -a categories=('videogames' 'music' 'fun' 'shortfilms' 'news' 'sport' 'auto' 'animals' 'people' 'webcam' 'creation' 'school' 'lifestyle' 'tech' 'travel' 'tv');
#random=$((RANDOM%${#categories[@]}-1))
#CATEGORY=${categories[$random]} #<--- Randomly select a category


#declare -a languages=('en' 'cn' 'ja' 'ru' 'tr' 'pt' 'fa' 'ko' 'it' 'da' 'ur' 'vi' 'pl' 'lv' 'id' 'he' 'fr');
#random2=$((RANDOM%${#languages[@]}-1))
#LANGUAGE=${languages[$random2]} #<--- Randomly select a language
echo -n "Getting access token..."

curl -s --output out.txt --data 'grant_type=password&client_id='$APIKEY'&client_secret='$APISECRET'&username='$USERNAME'&password='$PASSWORD'&scope='$SCOPE'' https://api.dailymotion.com/oauth/token


var1=$(grep "access_token" out.txt | cut -d: --complement -f1)

acc_token=$(echo $var1 | cut -d, -f1 | cut -d\" --complement -f1 | cut -d\" -f1)
lineclear
echo -n "Getting authorization..."

curl -s --output out.txt --header "Authorization: Bearer $acc_token" \
     "https://api.dailymotion.com/file/upload"

curl -s --output out.txt -i https://api.dailymotion.com/file/upload?access_token="$acc_token"

upload_url=$(grep "upload_url" out.txt | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1 | sed 's/\\//g')

lineclear
echo -n "Getting video url..."
curl -s --output out.txt --request POST \
     --form 'file=@'"$FILE" \
     "$upload_url"
video_url=$(grep "url" out.txt | cut -d: --complement -f1-10 | cut -d\" --complement -f1 | cut -d\" -f1 | sed 's/\\//g')

lineclear
echo "Uploading video..."
curl -s --output out.txt --request POST \
     --header "Authorization: Bearer $acc_token" \
     --form 'url='"$video_url" \
	 --form 'language='"$LANGUAGE" \
     --form 'title='"$TITLE" \
     --form 'channel='"$CATEGORY" \
	 --form 'tags='"$TAGS" \
     --form 'published=true' \
     "https://api.dailymotion.com/videos"
video_id=$(grep "id" out.txt | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1 )
if [[ "$video_id" == "code" ]]
then
	error=$(grep "message" out.txt | cut -d: --complement -f1-3 | cut -d\" --complement -f1 | cut -d\" -f1)
	echo "$error"
else
	echo "Video uploaded with id $video_id" 
fi
