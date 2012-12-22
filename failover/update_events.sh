#!/bin/bash

source `dirname $0`/config.sh

# Schedule und Streams runterladen
for lang in $languages; do
  download http://events.ccc.de/congress/2012/Fahrplan/schedule.$lang.xml $output/schedule.$lang.xml
  download http://www.noxymo.com/29c3/streams_${lang}_remote.html $output/streams_${lang}_remote.html
done

# Semantic Media Wiki (PRE 1.8.0 Installationsi & NEW JSON COMPATIBLE STUFF)
# DEACTIVATED FOR COMPATIBILITY WITH EXISTING APP
# download "https://events.ccc.de/congress/2012/wiki/Special:Ask/-5B-5BCategory:Assembly-5D-5D/-3F%3Duri-23/-3FDescription/-3FLecture-20seats/-3FName-20of-20location/-3FWeblink/-3FOrga-20contact/-3FLocation-20opened-20at/-3FPlanned-20workshops/-3FPlanning-20notes/-3FBrings-20stuff/-3FPerson-20organizing/mainlabel%3Duri/offset%3D20/limit%3D500/searchlabel%3D/format%3Djson" $output/assemblies.json

# download "https://events.ccc.de/congress/2012/wiki/Special:Ask/-5B-5BCategory:ScheduleEntry-5D-5D/-3FDescription/-3FStart-20time/-3FEnd-20time/-3FEntry-20location/-3FPerson-20organizing/-3FOrga-20contact/-3FDuration/mainlabel%3D/offset%3D20/limit%3D500/searchlabel%3D/format%3Djson" $output/workshops.json

# Semantic Media Wiki (LEGACY SUPPORT FOR 1.8.0 Installation; WILL RUn DEFUNCT IN 1.9.0)

# DOWNLOAD 29c3 ASSEMBLIES
download "https://events.ccc.de/congress/2012/wiki/Special:Ask/-5B-5BCategory:Assembly-5D-5D/-3F%3Duri-23/-3FDescription/-3FLecture-20seats/-3FMember-20seats/-3FName-20of-20location/-3FWeblink/-3FOrga-20contact/-3FLocation-20opened-20at/-3FPlanned-20workshops/-3FPlanning-20notes/-3FBrings-20stuff/-3FPerson-20organizing/mainlabel%3Duri/offset%3D20/limit%3D500/searchlabel%3D/format%3Djson/searchlabel%3DObsolete-20output/syntax%3Dobsolete/prettyprint%3Dyes/offset%3D0" $output/assemblies.json

# DOWNLOAD 29c3 WORKSHOPS (those scheduled)
# download "https://events.ccc.de/congress/2012/wiki/Special:Ask/-5B-5BCategory:ScheduleEntry-5D-5D/-3FDescription/-3FStart-20time/-3FEnd-20time/-3FEntry-20location/-3FPerson-20organizing/-3FOrga-20contact/-3FDuration/mainlabel%3D/offset%3D20/limit%3D500/searchlabel%3D/format%3Djson/searchlabel%3DObsolete-20output/syntax%3Dobsolete/prettyprint%3Dyes/offset%3D0" $output/workshops.json

download "https://events.ccc.de/congress/2012/wiki/Special:Ask/-5B-5BCategory:Workshop-5D-5D/-3FDescription/-3FStart-20time/-3FEnd-20time/-3FEntry-20location/-3FPerson-20organizing/-3FOrga-20contact/-3FDuration/mainlabel%3D/offset%3D20/limit%3D500/searchlabel%3D/format%3Djson/searchlabel%3DObsolete-20output/syntax%3Dobsolete/prettyprint%3Dyes/offset%3D0" $output/workshops.json



echo '{"date_last_cached":"'`date --iso-8601=seconds`'"}' > $output/status_events.json
