#!/usr/bin/env bash


function get_volume {
	pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | cut -f 2 -d "/" | cut -d "%" -f 1 | xargs
}

function is_mute {
	amixer get Master | grep "%" | grep -oE "[^ ]+$" | grep off > /dev/null
}

function send_notification {
	iconSound="audio-volume-high"
	iconMuted="audio-volume-muted"
	if is_mute ; then
		dunstify -i $iconMuted -r 2593 -u normal "Muted"
	else
		volume=$(get_volume)
		bar=$(seq --separator="─" 0 "$(((volume - 1) / 4))" | sed "s/[0-9]//g")
		space=$(seq --separator=" " 0 "$(((100 - volume) / 4))" | sed "s/[0-9]//g")
		dunstify -i $iconSound -r 2593 -u normal "|$bar$space| $volume%"
	fi
}

case $1 in
	up)
		amixer -D pipewire set Master on > /dev/null
		pactl set-sink-volume @DEFAULT_SINK@ +5% > /dev/null
		send_notification
		canberra-gtk-play -i audio-volume-change -d "changeVolume"
		;;
	down)
		amixer -D pipewire set Master on > /dev/null
		pactl set-sink-volume @DEFAULT_SINK@ -5% > /dev/null
		send_notification
		canberra-gtk-play -i audio-volume-change -d "changeVolume"
		;;
	mute)
		amixer -D pipewire set Master 1+ toggle > /dev/null
		send_notification
		;;
esac
