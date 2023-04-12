#!/usr/bin/env bash

# Define a function to check if a sink is muted
function isMuted {
  local sink="$1"
  local muted=$(pactl list sinks | awk -v id="$sink" '$0 ~ "Sink #"id {
    while ($0 !~ /Mute:/) { # Skip lines until "Mute:" is found
      getline;
    }
    if ($2 == "yes") { # Check if the sink is muted
      print "1"; # Return 1 if muted
    } else {
      print "0"; # Return 0 if not muted
    }
  }')
  echo "$muted"
}

# Set a counter variable to 0
COUNTER=0

# Find the ID of the relevant sink
RELEVANT_SINK=$(pactl list short sinks | awk '/alsa_output.pci-0000_06_04.0.analog-stereo/{print $1}')

# Loop forever
while :; do
  # Check if the relevant sink is not muted and there is at least one sink input
  IS_MUTED=$(isMuted $RELEVANT_SINK)
  if [ "$IS_MUTED" -eq 0 ] && [ -n "$(pactl list short sink-inputs)" ]; then
    # Turn on the device
    curl http://10.0.0.46/cm\?cmnd\=Power%20on
    COUNTER=0 # Reset the counter
  else
    COUNTER=$(( COUNTER + 1 )) # Increment the counter

    # If the counter reaches 140 (45 seconds in total) turn off the device
    if [[ $COUNTER -eq 140 ]]; then
      COUNTER=0 # Reset the counter
      curl http://10.0.0.46/cm\?cmnd\=Power%20off
    fi
  fi

  sleep 0.25 # Wait for 0.25 seconds before checking again
done

