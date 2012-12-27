#!/bin/bash

basedir=`dirname $0`
output=$basedir/data
images=$output/images
languages="de en"

# Verzeichnisse anlegen
mkdir -p $images

# Script abbrechen, wenn ein Fehler auftritt
#set -e

function download {
  url=$1
  out=$2
  tmp=/tmp/$$.tmp

  echo $url
  curl --silent --insecure --fail "$url" > $tmp && mv $tmp $out
}

function cachesite {
  url=$1
  out=$2
  tmp=/tmp/$$.tmp
  urlEscaped=`echo $url | sed -e 's!\/!\\\/!g'`
  echo $urlEscaped
  echo $url
  curl --silent --insecure --fail "$url" > $tmp && more $tmp | sed -n "1h;1!H;\${;g;s/<nav.*<\/nav>/<div style=\"margin:0px;background-color:#e00;color:#fff;padding:10px;font-size:18px;font-weight:bold;text-align:center;\"\>WARNING THIS IS <u\>UNSECURE AND CACHED<\/u\> HTML CONTENT ONLY TO WORKAROUND SSL ISSUES OF THE CONGRESS WIKI ON iOS DEVICES. IMAGES AND OTHER RESOURCES WILL NOT LOAD PROPERLY. OPEN THE <A href=\""$urlEscaped"\"\>ORIGINAL URL HERE<\/A\> PLEASE.<\/div\>/g;p;}" > $out
}

# working sed command
# from http://austinmatzko.com/2008/04/26/sed-multi-line-search-and-replace/
# sed -n '1h;1!H;${;g;s/<nav.*<\/nav>/<div style=\"margin:0px;background-color:#f00;color:#fff;padding:10px;font-size:24px;text-align:center;\"\><h1\>WARNING THIS IS CACHED CONTENT<BR\>TO WORKAROUND SSL RESTRICTIONS.<BR\>IMAGES WILL NOT LOAD PROPERLY.<\/h1\><\/div\>/g;p;}' > TenForwardX.html

#working sed command with double quotes
# sed -n "1h;1!H;\${;g;s/<nav.*<\/nav>/<div style=\"margin:0px;background-color:#e00;color:#fff;padding:10px;font-size:18px;font-weight:bold;text-align:center;\"\>WARNING THIS IS <u\>UNSECURE AND CACHED<\/u\> CONTENT TO WORKAROUND SSL RESTRICTIONS OF THE CONGRESS WIKI. IMAGES AND OTHER RESOURCES WILL NOT LOAD PROPERLY. OPEN THE <A href=\""$url"\"\>ORIGINAL URL HERE<\/A\> PLEASE.<\/div\>/g;p;}"
