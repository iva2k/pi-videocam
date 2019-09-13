#!/bin/bash

webcam=/dev/video0
fb=/dev/fb0
width=1600
height=1200
rate=5/1
format=YUY2

for i in "$@"
do
case $i in
  -d=*|--device=*)
    webcam="${i#*=}"
    shift # past argument=value
    ;;
  -o=*|--output=*)
    fb="${i#*=}"
    shift # past argument=value
    ;;
  -w=*|--width=*)
    width="${i#*=}"
    shift # past argument=value
    ;;
  -h=*|--height=*)
    height="${i#*=}"
    shift # past argument=value
    ;;
  -r=*|--rate=*)
    rate="${i#*=}"
    shift # past argument=value
    ;;
  -f=*|--format=*)
    format="${i#*=}"
    shift # past argument=value
    ;;
  *)
    printf "Unknown option '$i'.\n"
    printf "Usage: $0 [options].\n"
    exit 1
    ;;
esac
done

gst-launch-1.0 -v v4l2src device=$webcam ! video/x-raw,width=$width,height=$height, framerate=$rate, format=$format ! videoconvert ! fbdevsink device=$fb

