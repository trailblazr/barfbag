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

