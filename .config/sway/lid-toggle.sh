#!/usr/bin/env bash
if rg -q open /proc/acpi/button/lid/LID0/state; then
    swaymsg output eDP-1 enable
else
    swaymsg output eDP-1 disable
fi
