#!/bin/bash

source `dirname $0`/config.sh

# Alle SSL protected contents downloaden, die sonst einen fail wegen SSL cert machen

cachesite https://events.ccc.de/congress/2012/wiki/How_To_Survive $output/How_To_Survive.html
cachesite https://events.ccc.de/congress/2012/wiki/Frequently_Asked_Questions $output/Frequently_Asked_Questions.html
cachesite https://events.ccc.de/congress/2012/wiki/Main_Page $output/Main_Page.html
cachesite https://events.ccc.de/congress/2012/wiki/Lightning_Talks $output/Lightning_Talks.html
cachesite https://events.ccc.de/congress/2012/wiki/Projects $output/Projects.html
cachesite https://events.ccc.de/congress/2012/wiki/Lounge $output/Lounge.html
cachesite https://events.ccc.de/congress/2012/wiki/TenForward $output/TenForward.html
cachesite https://events.ccc.de/congress/2012/wiki/Accommodation $output/Accommodation.html
cachesite https://events.ccc.de/congress/2012/wiki/Travel $output/Travel.html
cachesite https://events.ccc.de/congress/2012/wiki/Local_Transport $output/Local_Transport.html
cachesite https://events.ccc.de/congress/2012/wiki/Useful_Places $output/Useful_Places.html
cachesite https://events.ccc.de/congress/2012/wiki/Food_and_drinks $output/Food_and_drinks.html
cachesite https://events.ccc.de/congress/2012/wiki/Volunteers $output/Volunteers.html
cachesite https://events.ccc.de/congress/2012/wiki/After_Party $output/After_Party.html

echo '{"date_last_cached":"'`date --iso-8601=seconds`'"}' > $output/status_wikipages.json
