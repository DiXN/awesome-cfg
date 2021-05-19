#! /usr/bin/env bash

PATTERN="(.+) - (.*)"

if [ "$1" == "album" ]; then
  BEARER="$(jq -r ".access_token" "/home/$(whoami)/.config/spotify-tui/.spotify_token_cache.json")"
  mkdir -p "/tmp/spot"
  ALBUM_PATH="/tmp/spot/album.png"

  if [ -n "$BEARER" ]; then
    ALBUM_ID="$(spt playback --share-album | awk 'BEGIN { FS = "/" }; {print $5}')"
    ALBUM_IMG=$(curl -s -X "GET" "https://api.spotify.com/v1/albums/$ALBUM_ID" \
     -H "Accept: application/json" -H "Content-Type: application/json" \
     -H "Authorization: Bearer $BEARER" | jq -r ".images[1].url")
    curl -sL "$ALBUM_IMG" > "$ALBUM_PATH" && echo "$ALBUM_PATH"
  else
    ALBUM_IMG=$(curl -sL "$(spt playback --share-album)" | pcregrep -o1 "src=\"(https:\/\/i\.scdn\.co\/image\/.*?)\"" | head -n 1)
    # ALBUM_ID=$(echo "$ALBUM_IMG" | awk 'BEGIN { FS = "/" }; {print $5}')
    # ALBUM_PATH="/tmp/spot/${ALBUM_ID}.png"
    curl -sL "$ALBUM_IMG" > "$ALBUM_PATH" && echo "$ALBUM_PATH"
  fi
elif [ "$1" == "song" ]; then
  PLAYING="$(spt playback -s)"
  SONG="$(echo "$PLAYING" | pcregrep -o1 "$PATTERN")"
  echo "${SONG:2}"
elif [ "$1" == "artist" ]; then
  PLAYING="$(spt playback -s)"
  ARTIST="$(echo "$PLAYING" | pcregrep -o2 "$PATTERN")"
  echo "$ARTIST"
else
  PLAYING="$(spt playback -s 2>&1)"
  ARTIST="$(echo "$PLAYING" | pcregrep -o2 "$PATTERN")"
  SONG="$(echo "$PLAYING" | pcregrep -o1 "$PATTERN")"
  if [[ ${SONG::1} == "▶" ]]; then
    echo 'playing'
    echo "${SONG:2}"
    echo "$ARTIST"
  elif [[ $PLAYING == "Error: no context available" ]]; then
    echo 'not playing'
    echo 'Nothing Playing'
    echo ''
  else
    echo 'not playing'
    echo "${SONG:2}"
    echo "$ARTIST"
  fi
fi


