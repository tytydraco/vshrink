#!/usr/bin/env bash
shopt -s globstar

shrink() {
	local video
	local filename
	local extension
	
	local tmp
	
	video="$1"

	filename=$(basename -- "$video")
	extension="${filename##*.}"
	
	tmp="tmp.$extension"
	
	height="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$video")"
	[[ "$height" -le 720 ]] && return

	echo "[SHRINKING] $filename"
	if ffmpeg -y -i "$video" -map 0 -scodec copy -vf scale="-2:720" "$tmp"
	then
		rm -f "$video"
		mv "$tmp" "$video"
	else
		echo "[ERROR]"
		rm "$tmp"
	fi
}

for video in **/*.*
do
	[[ "$video" == "$0" ]] && continue
	shrink "$video"
done
