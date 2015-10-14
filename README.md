DailyMotionUpload
=================

Bash script to upload videos to DailyMotion from command line, very simple to configure.

###Usage
```bash 
	Usage: ./dmUpload.sh -u username -p password -k api_key -s api_secret -c category [ -t "title" ] [ -l language ] video.mp4 [ tag,another tag ]
Options:
--help	Show this extremely helpful message.
--multiple	Upload multiple videos
To upload more than one video, run the program using the following syntax:

./dmUpload.sh -u username -p password -k api_key -s api_secret -l language --multiple list1.txt list2.txt

The text files must contain the following line for every video:

"title" [ tag,another tag ] video.mp4 category

If no title is specified, the filename (without extension) is used as title.
Default language is english (en).
