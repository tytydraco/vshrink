#!/usr/bin/env bash
shopt -s globstar

shrink() {
	local video
	local filename
	local extension
	
	local metadata
	local width
	local rate
	
	local args
	args=()
	
	video="$1"

	filename=$(basename -- "$video")
	extension="${video##*.}"
	filename="${video%.*}"
	
	metadata="$(ffprobe -v error -select_streams v:0 -show_entries stream=height,r_frame_rate -of csv=p=0 "$video")"
	width="$(echo "$metadata" | awk -F , '{print $1}')"
	rate="$(( "$(echo "$metadata" | awk -F , '{print $2}')" )) "

	[[ "$width" -gt 720 ]] && args+=("-vf" "scale='-2:720'")
	[[ "$rate" -gt 24 ]] && args+=("-vsync" "vfr" "-r" "24")

	[[ "${#args[@]}" -eq 0 ]] && return

	echo "[SHRINKING] $filename"
	if ffmpeg -y -i "$video" -f matroska "${args[@]}" tmp
	then
		rm -f "$video"
		mv tmp "$filename.mkv"	
	else
		echo "[ERROR]"
		rm tmp
	fi
}

for video in **/*.*
do
	[[ "$video" == "$0" ]] && continue
	shrink "$video"
done
