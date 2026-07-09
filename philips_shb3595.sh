#!/bin/bash

systemctl --user daemon-reload
systemctl --user mask pulseaudio
systemctl --user --now enable pipewire-media-session.service
pactl info
systemctl --user restart pipewire
