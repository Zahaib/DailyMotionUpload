#!/bin/bash

#client_id="<CLIENT ID>"
#client_secret="<CLIENT SECRET>"
#username="<USERNAME>"
#password="<PASSWORD>"
#scope="<SCOPE>"

curl -s --output out.txt --data 'grant_type=password&client_id='$client_id'&client_secret='$client_secret'&username='$username'&password='$password'&scope='$scope'' https://api.dailymotion.com/oauth/token

var1=$(grep "access_token" out.txt | cut -d: --complement -f1)
#cat out.txt
#printf '\n'
acc_token=$(echo $var1 | cut -d, -f1 | cut -d\" --complement -f1 | cut -d\" -f1)

curl -s --output out.txt -i https://api.dailymotion.com/file/upload?access_token="$acc_token"
#cat out.txt
#printf '\n'
upload_url=$(grep "upload_url" out.txt | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1 | sed 's/\\//g')

#echo $upload_url

curl -s --output out.txt -F 'file=@/home/zahaib/twoSec.mp4' "$upload_url"
#cat out.txt
#printf '\n'
video_url=$(grep "url" out.txt | cut -d: --complement -f1-10 | cut -d\" --complement -f1 | cut -d\" -f1 )
#echo $video_url

curl -s --output out.txt -d 'url='$video_url'' https://api.dailymotion.com/me/videos?access_token="$acc_token"
#cat out.txt
#printf '\n'
video_id=$(grep "id" out.txt | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1 )

curl -s --output out.txt -d 'title=MoreVid&channel=sport&tags=was' https://api.dailymotion.com/video/"$video_id"?access_token="$acc_token"
#cat out.txt
#printf '\n'

curl -s --output out.txt -d 'published=true' https://api.dailymotion.com/video/"$video_id"?access_token="$acc_token"
#cat out.txt
#printf '\n'

echo "Video uploaded with id $video_id" 


