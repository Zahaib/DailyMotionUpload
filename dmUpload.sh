#!/bin/bash
APIKEY=""
APISECRET=""
USERNAME=""
PASSWORD=""
SCOPE="read+write"
FILE="/home/foo/bar.mp4"
TAGS="foo,bar"
#TITLE=$(basename "$FILE")
#TITLE="${TITLE%.*}" #<--- Same title as file's name
TITLE="foobar"

#declare -a categories=('videogames' 'music' 'fun' 'shortfilms' 'news' 'sport' 'auto' 'animals' 'people' 'webcam' 'creation' 'school' 'lifestyle' 'tech' 'travel' 'tv');
#random=$((RANDOM%${#categories[@]}-1))
#CATEGORY=${categories[$random]} #<--- Randomly select a category
CATEGORY="videogames"

#declare -a languages=('en' 'cn' 'ja' 'ru' 'tr' 'pt' 'fa' 'ko' 'it' 'da' 'ur' 'vi' 'pl' 'lv' 'id' 'he' 'fr');
#random2=$((RANDOM%${#languages[@]}-1))
#LANGUAGE=${languages[$random2]} #<--- Randomly select a language
LANGUAGE="en"

curl -s --output out.txt --data 'grant_type=password&client_id='$APIKEY'&client_secret='$APISECRET'&username='$USERNAME'&password='$PASSWORD'&scope='$SCOPE'' https://api.dailymotion.com/oauth/token

var1=$(grep "access_token" out.txt | cut -d: --complement -f1)

acc_token=$(echo $var1 | cut -d, -f1 | cut -d\" --complement -f1 | cut -d\" -f1)

curl -s --output out.txt --header "Authorization: Bearer $acc_token" \
     "https://api.dailymotion.com/file/upload"

curl -s --output out.txt -i https://api.dailymotion.com/file/upload?access_token="$acc_token"

upload_url=$(grep "upload_url" out.txt | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1 | sed 's/\\//g')

curl -s --output out.txt --request POST \
     --form 'file=@'"$FILE" \
     "$upload_url"
video_url=$(grep "url" out.txt | cut -d: --complement -f1-10 | cut -d\" --complement -f1 | cut -d\" -f1 | sed 's/\\//g')

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
