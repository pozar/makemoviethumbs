#!/bin/bash

inputfile="TheWaspWoman1959"
inputext="mp4"
start=0
end=300
interval_secs=5

# Get rid of previous thumbnails..
rm *.jpeg
# Create sequence...
ffmpeg -loglevel panic -i $inputfile.$inputext -ss $start -t $end -f image2 -qscale 2 -vf fps=1/$interval_secs %d.jpeg
# Get a listing of the thumbnail filenames...
arr=( $(ls *.jpeg) )
# Number of filenames
qnt=${#arr[@]}
# First filename will be #1..
i=1
while [ $i -le $qnt ]; do
    let totalsec=i*interval_secs
    let sec=(totalsec % 60)
    let min=(totalsec % 3600)/60
    let hour=totalsec/3600
    thumb_filename=$(printf "%s-%02d_%02d_%02d.jpeg" "$inputfile" "$hour" "$min" "$sec")
    mv $i.jpeg $thumb_filename
    let i=i+1
done

