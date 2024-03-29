# pi-videocam / microscope pi

This project makes Raspberry Pi into a video camera, e.g. for using it with HDMI monitor and a simple USB microscope.

Either clone Github repo <https://github.com/iva2k/pi-videocam> directly to Pi or upload all files to it over SCP/SSH from Windows (if Git is installed on Windows, it has scp implementation) using ```upload.cmd```, then SSH to Pi and run ```install.sh``` from one of subfolders:

* webcam-server.motion - streams video over Network using Motion package
* webcam-video.gstreamer - shows video on HDMI monitor using GStreamer/framebuffer

Once installed, corresponding service will load on boot.

Note: either -server or -video can run at one time. If both are installed, one of them will not work due to clashing for the camera (something TODO/implement later).

# Dev.Notes

* install raspbian lite
* change password
* enable SSH
* optional: connect to WiFi (or use LAN port for networking)
* connect USB camera

Check if webcam is supported:

```
sudo apt-get install fswebcam

sudo usermod -a -G video <username>
sudo usermod -a -G video pi

# test:
fswebcam image.jpg
```

Check camera

```
lsusb
v4l2-ctl --list-formats
v4l2-ctl --list-formats-ext
```

## Use GStreamer (Webcam) ##

```
sudo apt-get update
sudo apt-get install gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad
```

Test image:

```
gst-launch-1.0 videotestsrc ! fbdevsink device=/dev/fb0
```

Working command:

```
gst-launch-1.0 -v v4l2src device=/dev/video0 ! video/x-raw,width=1600,height=1200, framerate=5/1, format=YUY2 ! videoconvert ! fbdevsink device=/dev/fb0
```

Non-working tries:

```
?? omxh264dec ! autovideosink:
?? gst-launch-1.0 -v v4l2src device=/dev/video0 ! video/x-raw,width=1600,height=1200, framerate=5/1, format=YUY2 ! videoconvert ! autovideosink
?? gst-launch-1.0 -v v4l2src device=/dev/video0 ! video/x-raw,width=1600,height=1200, framerate=5/1, format=YUY2 ! omxh264dec ! fbdevsink device=/dev/fb0

?? gst-launch-1.0 -v v4l2src device=/dev/video0 ! image/jpeg,width=1600,height=1200,framerate=30/1 ! jpegparse ! jpegdec ! xvimagesink

gst-launch-1.0 -v v4l2src device=/dev/video0 ! image/jpeg,width=1600,height=1200, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! fbdevsink device=/dev/fb0


#(stream out)# !  jpegenc !  rtpjpegpay !  udpsink host=192.168.178.124 port=5200
```

## GPU-accelerated GStreamer ##

https://raspberrypi.stackexchange.com/a/29549

```
sudo apt-get update
sudo apt-get install gstreamer1.0
then check with:

gst-inspect-1.0 | grep omx
 omx:  omxmpeg2videodec: OpenMAX MPEG2 Video Decoder
 omx:  omxmpeg4videodec: OpenMAX MPEG4 Video Decoder
 omx:  omxh263dec: OpenMAX H.263 Video Decoder
 omx:  omxh264dec: OpenMAX H.264 Video Decoder
 omx:  omxtheoradec: OpenMAX Theora Video Decoder
 omx:  omxvp8dec: OpenMAX VP8 Video Decoder
 omx:  omxmjpegdec: OpenMAX MJPEG Video Decoder
 omx:  omxvc1dec: OpenMAX WMV Video Decoder
 omx:  omxh264enc: OpenMAX H.264 Video Encoder
 omx:  omxanalogaudiosink: OpenMAX Analog Audio Sink
 omx:  omxhdmiaudiosink: OpenMAX HDMI Audio Sink

```



Other (non-working?) ways:

https://raspberrypi.stackexchange.com/a/10370

```
sudo nano /etc/apt/sources.list
deb http://vontaene.de/raspbian-updates/ . main

sudo apt-get update
sudo apt-get install gstreamer1.0

gst-inspect-1.0 | grep omx
```

```
#Did't compile:
#https://raspberrypi.stackexchange.com/a/4628
#
#sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
#sudo apt-get -y install git-core
#
#sudo apt-get update
#sudo apt-get upgrade -y
#sudo rpi-update
#sudo reboot
#
#cd $HOME 
#git clone -b 0.10 git://anongit.freedesktop.org/gstreamer/gst-omx
#sudo apt-get install -y autoconf gtk-doc-tools libtool 
#sudo apt-get install libglib2.0-dev
#sudo apt-get install libgstreamer0.10-dev
#sudo apt-get install libgstreamer-plugins-base0.10-dev
#
#cd gst-omx
##? ./autogen.sh --noconfigure --with-omx-header-path=/opt/vc/include/IL --with-omx-target=rpi
##? ./configure --prefix=/home/pi/omx
#
## ./autogen.sh --noconfigure --with-omx-header-path=/opt/vc/include/IL --with-omx-target=rpi
## ln /opt/vc/include/IL/OMX_Broadcom.h ./omx/OMX_Broadcom.h -s
#
#LDFLAGS='-L/opt/vc/lib' CPPFLAGS='-I/opt/vc/include -I/opt/vc/include/IL -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux' ./autogen.sh  --with-omx-target=rpi
#
#make 
#make install
#
#./autogen.sh --with-omx-header-path=/opt/vc/include/IL --with-omx-target=rpi
#
```

## Use GStreamer (Pi Camera) ##

```
sudo apt-get update
sudo apt-get install gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad


raspivid -t 0 -w 1600 -h 1200 -fps 30 -b 2000000 -o - | \
gst-launch-1.0 -v fdsrc ! h264parse ! rtph264pay config-interval=1 pt=96 ! gdppay ! tcpserversink host=<IP-OF-YOUR-PI> port=5000


gst-launch-1.0 -v tcpclientsrc host=<IP-OF-YOUR-PI> port=5000 ! gdpdepay ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink sync=false

```

## GStreamer on Linux / Windows: ##

https://gstreamer.freedesktop.org/documentation/installing/on-windows.html

https://gstreamer.freedesktop.org/documentation/installing/on-mac-osx.html


## Autostart Screen Video on Boot ##

```
sudo nano /usr/local/bin/webcam-video.sh
#!/bin/bash
gst-launch-1.0 -v v4l2src device=/dev/video0 ! video/x-raw,width=1600,height=1200, framerate=5/1, format=YUY2 ! videoconvert ! fbdevsink device=/dev/fb0
```

```
sudo chmod +x /usr/local/bin/webcam-video.sh

sudo nano /etc/systemd/system/webcam-video.service

[Unit]
Description=Network Video Streaming
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/webcam-video.sh
StandardOutput=journal+console
User=pi
Restart=on-failure

[Install]
WantedBy=multi-user.target
```


Test:

```
sudo systemctl start webcam-video.service
```

Enable:

```
sudo systemctl enable webcam-video.service
```



## Autostart Network Streaming on Boot ##

```
sudo nano /usr/local/bin/network-streaming.sh
#!/bin/bash
raspivid -t 0 -w 1920 -h 1080 -fps 30 -vf -hf -b 2000000 -o - | \
gst-launch-1.0 -v fdsrc ! h264parse ! rtph264pay config-interval=1 pt=96 ! gdppay ! tcpserversink host=<IP-OF-YOUR-PI> port=5000
```

```
sudo chmod +x /usr/local/bin/network-streaming.sh

sudo nano /etc/systemd/system/network-streaming.service

[Unit]
Description=Network Video Streaming
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/network-streaming.sh
StandardOutput=journal+console
User=pi
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Test:

```
sudo systemctl start network-streaming.service
```

Enable:

```
sudo systemctl enable network-streaming.service
```

## Motion ##

```
sudo apt-get install motion

sudo nano /etc/motion/motion.conf
...

sudo nano /etc/default/motion
...
```








## mjpg-streamer ##

https://iotalot.com/2016/05/28/video-streaming-using-raspberry-pi-3-and-usb-webcam/



## Works With ##

### 2MP 200x USB Microscope ###

One handy / inexpensive 2M unit: 

<https://www.amazon.com/gp/product/B005P40OXY>

<https://www.amazon.com/gp/product/B0184CCOY0>


```
v4l2-ctl --list-formats-ext

ioctl: VIDIOC_ENUM_FMT
        Type: Video Capture

        [0]: 'YUYV' (YUYV 4:2:2)
                Size: Discrete 640x480
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 352x288
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 320x240
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 176x144
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 160x120
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 800x600
                        Interval: Discrete 0.050s (20.000 fps)
                Size: Discrete 1280x960
                        Interval: Discrete 0.111s (9.000 fps)
                Size: Discrete 1600x1200
                        Interval: Discrete 0.200s (5.000 fps)
        [1]: 'MJPG' (Motion-JPEG, compressed)
                Size: Discrete 640x480
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 352x288
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 320x240
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 176x144
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 160x120
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 800x600
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 1280x960
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 1600x1200
                        Interval: Discrete 0.033s (30.000 fps)
                        Interval: Discrete 0.050s (20.000 fps)
                        Interval: Discrete 0.067s (15.000 fps)
                        Interval: Discrete 0.100s (10.000 fps)
                        Interval: Discrete 0.200s (5.000 fps)5
```

## Camera Button ##

It would be nice to have camera button tied to making frame captures, e.g. to a USB stick. So here's an ongoing investigation on how to implement:

https://unix.stackexchange.com/questions/398660/detecting-usb-camera-button-event

https://stackoverflow.com/questions/48353121/reading-usb-camera-button-press-event

https://stackoverflow.com/questions/48612210/grab-signal-from-webcam-button

used ```cat /proc/bus/input/devices``` to find event#.

```
sudo apt-get install evtest
sudo evtest /dev/input/event3
```

but no events came. Somehow need to "activate" camera for it to send events. Did not find how that "activation" should be done. Apparently, just running gstreamer on it does not activate it.

Digging further, v4l2src can have extra parameters:

* extra-controls - maps to (or passes values to) v4l2-ctl

Though that did not uncover how to enable the button.
