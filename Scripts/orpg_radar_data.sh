#! /bin/bash

# Raytheon ORPG Radar & Radar Data Switching Utility
#
# The purpose of this program is to allow for an easy way
# to switch the radar and change the type of radar data.
# Also, this script will allow the radar data to auto switch.
#
# Created by Will Leverenz on 12/11/2007
# Updated by W.E. Smith on 4/28/2014

# FUNCTIONS

# --- Function One: Print Page ---

function print_main_page {

# Print main page
clear
echo -e "Welcome to the Raytheon ORPG"
echo -e "Radar & Radar Data Switching Utility."
echo -e "Version: Build 9 $VERSION\n"
echo -e "Enter the name of the radar you would like to switch to (kbox)"
echo -e "or select the number from the following radar data options: \n"

echo -e "1. KTLX: Tornado Outbreak"
echo -e "2. KEWX: Tornado Outbreak"
echo -e "3. KPAH: Tornado Outbreak"
echo -e "4. KLWX: Winter Storm"
echo -e "5. KMOX: Tropical Cyclone"
echo -e "6. KBOX: Clear Air"
echo -e "7. KDOX: Severe Weather"
echo -e "8. KDYX: Wind Farm 03192008"
echo -e "9. KDYX: Wind Farm 04082008"
echo -e "10. KTLX: Super-res Clear Sky 12092008"
echo -e "11. KCRI: Super-res Convective VCP test 10302007"
echo -e "12. KTLX: Super-res Tropical Storm Erin"
echo -e "13. KFFC: Super-res Hail and Tornadoes"
echo -e "14. KRLX: Super-res High Winds"
echo -e "15. KFTG: Super-res Winter Storm"
echo -e "16. KLWX: June 2012 Derecho Dual Pol"
echo -e "17. KOUN: Dual Pol Severe"
echo -e "18. KSGF: Joplin EF5 Event - May 22, 2011"
echo -e "19. NOP4: SAILS - 20130520"
echo -e "A. Rotate through all of the above options"
echo -e "H. What does this script do?"
echo -e "I. Information about data selections below\n"

echo -e "Enter name, number, or letter: "

}

# --- Function Two: Play Radar Data ---

function play_radar_data {

echo -e "Stopping radar playback...\n"
PID=`ps -wef|grep play_a2 | awk ' { print $2 } '`
kill -9 $PID
echo -e "Starting radar playback...\n"

case $NUMBER in

1 )  DIR="/home/$VERSION/radar_data/KTLX_tornado_outbreak/";;
2 )  DIR="/home/$VERSION/radar_data/KEWX_tornado_outbreak/";;
3 )  DIR="/home/$VERSION/radar_data/KPAH_tornado_outbreak/";;
4 )  DIR="/home/$VERSION/radar_data/KLWX_winter_storm/";;
5 )  DIR="/home/$VERSION/radar_data/KMOB_tropical_cyclone/";;
6 )  DIR="/home/$VERSION/radar_data/KBOX_clear_air/";;
7 )  DIR="/home/$VERSION/radar_data/KDOX_severe_weather/";;
8 )  DIR="/home/$VERSION/radar_data/WindFarm20080317Ext/";;
9 )  DIR="/home/$VERSION/radar_data/KDYX_wind_farm_04082008/";;
10 )  DIR="/home/$VERSION/radar_data/KTLX_clear_sky/";;
11 )  DIR="/home/$VERSION/radar_data/KCRI_conv_VCP_test/";;
12 )  DIR="/home/$VERSION/radar_data/KTLX_Tropical_Storm_Erin/";;
13 )  DIR="/home/$VERSION/radar_data/KFFC_Hail_Tornados/";;
14 )  DIR="/home/$VERSION/radar_data/KRLX_High_Winds/";;
15 )  DIR="/home/$VERSION/radar_data/KFTG_Winter_Storm/";;
16 )  DIR="/home/$VERSION/radar_data/KLWX_Derecho_Dual_Pol/";;
17 )  DIR="/home/$VERSION/radar_data/KOUN_Dualpol_Severe/";;
18 )  DIR="/home/$VERSION/radar_data/KSGF_Joplin_EF5/";;
19 )  DIR="/home/$VERSION/radar_data/NOP4-SAILS-20130520/";;
* )  echo -e "\nThe selection was: $SELECTION"
     echo -e "That is an invalid selection!!!"
     echo -e "Remeber, you can only select a number, a letter,"
     echo -e "or a valid WSR-88D.  Please try again."
     echo -e "Press ENTER to return:"
     read;;
esac

# If the rotation option "A" has been selected play each weather event
# once and then move on to the next one; else, play the one weather 
# event continuously.  
 
echo -e "/home/$VERSION/bin/lnux_x86/play_a2"

if [[ "$SELECTION" == "A" ]]
then
/home/$VERSION/bin/lnux_x86/play_a2 -R -d $DIR
else
/home/$VERSION/bin/lnux_x86/play_a2 -c -R -d $DIR
fi

# Do not hold before going back; continuously play data 



}

# --- Function Three: Help

function help {

clear
echo -e "Raytheon ORPG Radar & Radar Data Switching Utility\n"
echo -e "The purpose of this program is to allow for an easy way"
echo -e "to switch the radar and change the type of radar data."
echo -e "Also, this script will allow the radar data to auto switch.\n"
echo -e "Created by Will Leverenz on 12/11/2007\n\n"

# Hold before returning
echo -e "Press enter to return to the main menu."
read

}

# --- Function Four: Radar Event Information

function info {

clear
echo -e "No information has been added."

# Hold before returning
echo -e "\nPress enter to return to the main menu."
read
}

# === MAIN BODY ===

clear

# Figure out what version the ORPG is

VERSION=`ls /home | grep v1.27 | grep -v data`
# Don't stop script unless it gets an interupt

while
true
do

print_main_page  # Function

read SELECTION

# Is the selection four characters long, if so likely a radar
CHAR_COUNT=`echo $SELECTION | wc -m`

if [ $CHAR_COUNT -eq 5 ]
then
clear
echo -e "Stopping radar playback...\n"
PID=`ps -wef|grep play_a2 | awk ' { print $2 } '`
kill -9 $PID
echo -e "Changing radar to $SELECTION...\n"
/home/$VERSION/bin/change_radar -r $SELECTION
echo -e "Radar name and information should be stated above."
echo -e "Press enter to return to the main menu."
read

else

# If the rotation has been selected, then enter a infinite loop

case $SELECTION in

A )  while
     true
     do
     # Keep running through sequence of numbers forever
     for NUMBER in `seq 1 9`
     do
     play_radar_data  # Function
     done
     done;;
H )  help;;  # Function
I )  info;;  # Function
* )  NUMBER=$SELECTION
     echo "$NUMBER & $SELECTION"
     play_radar_data;;  # Function
esac

fi
done
# EOF

