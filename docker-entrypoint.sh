#!/bin/bash

EMERGENCY=false
NOTIFY=true

CURRENT_MODE=default

# IPMI SETTINGS:
IPMIHOST=${IPMIHOST} 
IPMIUSER=${IPMIUSER} 
IPMIPW=${IPMIPW} 

# SLEEP SETTING:
SLEEP=${SLEEP:-30}

# Sensor
SENSOR=${SENSOR:-"Temp"}

DEC_HEX=$(printf '%x\n' $SET_SPEED)

# Fans

FAN_LOW_PERCENTAGE=${FAN_LOW_PERCENTAGE:-15}
FAN_LOW_THRESHOLD=${FAN_LOW_THRESHOLD:-30}

FAN_MEDIUM_PERCENTAGE=${FAN_MEDIUM_PERCENTAGE:-25}
FAN_MEDIUM_THRESHOLD=${FAN_MEDIUM_THRESHOLD:-37}

FAN_HIGH_PERCENTAGE=${FAN_HIGH_PERCENTAGE:-35}
FAN_HIGH_THRESHOLD=${FAN_HIGH_THRESHOLD:-43}

FAN_VERYHIGH_PERCENTAGE=${FAN_VERYHIGH_PERCENTAGE:-50}
FAN_VERYHIGH_THRESHOLD=${FAN_VERYHIGH_THRESHOLD:-47}

MAXTEMP="50"


function FanLow()
{
  if [ "$CURRENT_MODE" == "low" ] ; then
    echo "Maintaining current mode: $CURRENT_MODE"
    return 0
  fi

  echo "Info: Activating manual fan speeds (3000 RPM)"
  FanManual
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x10

  CURRENT_MODE=low
}

function FanMedium()
{
  if [ "$CURRENT_MODE" == "medium" ] ; then
    echo "Maintaining current mode: $CURRENT_MODE"
    return 0
  fi

  echo "Info: Activating manual fan speeds (5880 RPM)"
  FanManual
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x20

  CURRENT_MODE=medium
}

function FanHigh()
{
  if [ "$CURRENT_MODE" == "high" ] ; then
    echo "Maintaining current mode: $CURRENT_MODE"
    return 0
  fi


  echo "Info: Activating manual fan speeds (8880 RPM)"
  FanManual
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x30

  CURRENT_MODE=high
}

function FanVeryHigh()
{
  if [ "$CURRENT_MODE" == "veryhigh" ] ; then
    echo "Maintaining current mode: $CURRENT_MODE"
    return 0
  fi


  echo "Info: Activating manual fan speeds (14640 RPM)"
  FanManual
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x50

  CURRENT_MODE=veryhigh
}

function FanAuto()
{
  if [ "$CURRENT_MODE" == "auto" ] ; then
    echo "Maintaining current mode: $CURRENT_MODE"
    return 0
  fi


  echo "Info: Dynamic fan control Active ($CurrentTemp C)"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01

  CURRENT_MODE=auto
}

# Set the fans to manual mode, this should not be run on its own
function FanManual()
{
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
}

function gettemp()
{
  TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type temperature |grep -E ^$SENSOR |grep degrees |grep -Po '\d{2}' | tail -1)
  echo "$TEMP"
}

function healthcheck()
{
  if $EMERGENCY; then
    echo "Temperature is NOT OK ($CurrentTemp C). Emergency Status: $EMERGENCY"
  else
    echo "Temperature is OK ($CurrentTemp C). Emergency Status: $EMERGENCY"
  fi
}

function SetCorrectSpeed()
{
  CurrentTemp=$(gettemp)

  if [[ $CurrentTemp > $MAXTEMP ]]; then
    EMERGENCY=true
    NOTIFY=true
    FanAuto

  elif [[ $CurrentTemp > $FAN_VERYHIGH_THRESHOLD ]]; then
    EMERGENCY=false
    NOTIFY=false
    FanVeryHigh

  elif [[ $CurrentTemp > $FAN_HIGH_THRESHOLD ]]; then
    EMERGENCY=false
    NOTIFY=false
    FanHigh

  elif [[ $CurrentTemp > $FAN_MEDIUM_THRESHOLD ]]; then
    EMERGENCY=false
    NOTIFY=false
    FanMedium

  elif [[ $CurrentTemp > $FAN_LOW_THRESHOLD ]]; then
    EMERGENCY=false
    NOTIFY=false
    FanLow

  fi
}

function percentToHex {
  return $(printf '%x\n' $1)
}

function onExit {
  echo "Exiting... Setting fans back to auto..."
  FanAuto
}

trap onExit EXIT

# Start by setting the fans to auto
echo "Fetching current temperature...\n"

while :
do
  SetCorrectSpeed

  healthcheck

  echo "Sleeping for $SLEEP seconds..."
  sleep "$SLEEP"
done
