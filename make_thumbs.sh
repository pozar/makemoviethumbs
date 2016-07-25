#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
inputfile=""
interval_secs=0
starttime=0
endtime=0
average=0

show_help ()
{
    echo "$0:"
    echo "   -h (show help)"
    echo "   -v (verbose)"
    echo "   -f inputfile"
    echo "   -i interval_secs"
    echo "   -s starttime_secs"
    echo "   -e endtime_secs"
    echo "   -a total_images_averaged_over_the_duration_or_start_stop_time (will override interval_secs)"
}

while getopts "h?f:i:s:e:a:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    f)  inputfile=$OPTARG
        ;;
    i)  interval_secs=$OPTARG
        ;;
    s)  starttime=$OPTARG
        ;;
    e)  endtime=$OPTARG
        ;;
    a)  average=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ -z $inputfile ]; then
   echo We need a filename
   show_help
   exit 1
fi

if [ $endtime -eq 0 ]; then
   # When used to calculate average interverals or end time is not defined...
   endtime=`ffprobe -i $inputfile -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//'`
fi

if [ $average -gt 0 ]; then
   let duration=endtime-starttime
   let interval_secs=duration/average
fi

# Get rid of previous thumbnails and don't error if it doesn't find anything
rm *.jpeg || true
# Create sequence...
ffmpeg -loglevel panic -i $inputfile -ss $starttime -t $endtime -f image2 -qscale 2 -vf fps=1/$interval_secs %d.jpeg

# Drop off the filename extesion...
inputfile="${inputfile/.mp4/}"
# Get a listing of the thumbnail filenames...
arr=( $(ls *.jpeg) )
# Number of filenames
qnt=${#arr[@]}
# First filename will be #1..
i=1
while [ $i -le $qnt ]; do
    let totalsec=i*interval_secs
    let timestampsecs=totalsec+starttime
    let sec=(timestampsecs % 60)
    let min=(timestampsecs % 3600)/60
    let hour=timestampsecs/3600
    thumb_filename=$(printf "%s-%02d_%02d_%02d.jpeg" "$inputfile" "$hour" "$min" "$sec")
    mv $i.jpeg $thumb_filename
    let i=i+1
done
