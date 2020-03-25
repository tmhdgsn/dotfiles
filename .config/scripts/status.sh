#!/bin/bash
date_formatted=$(date "+%a %F %H:%M")
linux_version=$(uname -r | tr 'a-z' 'A-Z')
battery_status=$(cat /sys/class/power_supply/BAT1/capacity)

echo $linux_version $battery_status% $date_formatted
