#!/bin/bash

# Define the path to the loop_pngs.sh script
SCRIPT_PATH="/home/monzey/dotfiles/animate/loop_pngs.sh"

# Check if the script is running
if pgrep -x "loop_pngs.sh" > /dev/null
then
    # If the script is running, kill it
    pkill -x "loop_pngs.sh"
else
    # If the script is not running, start it
    "$SCRIPT_PATH" &
fi
