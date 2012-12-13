#!/bin/bash

source `dirname $0`/config.sh

# Bilder runterladen
person_ids=`fgrep -i "person id" $output/schedule.de.xml | sed -d'"' -f 2 |sort |uniq`
# secure version ;-)
# person_ids=`fgrep -i "<person id=" $output/schedule.de.xml | grep -o -P '([0-9]+)' |sort |uniq`

for id in $person_ids; do
  download http://events.ccc.de/congress/2012/Fahrplan/images/person-$id-128x128.png  $images/person-$id-128x128.png
done

echo '{"date_last_cached":"'`date --iso-8601=seconds`'"}' > $output/status_images.json
