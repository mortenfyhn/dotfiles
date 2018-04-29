############################################################
# Arduino                                                  #
############################################################

ARDUINO_MODEL="nano328"
USB_DEVICE="/dev/ttyUSB0"
BAUD_RATE="38400"

ino_build () { ino build -m $ARDUINO_MODEL }
ino_upload () { ino upload -m $ARDUINO_MODEL -p $USB_DEVICE }
ino_serial () { ino serial -b $BAUD_RATE -p $USB_DEVICE }
ino_clean () { ino clean }

ino_build_upload () {
  ino_build
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi
  ino_upload
}

ino_build_upload_serial () {
  ino_build
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi
  ino_upload
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi
  ino_serial
}
