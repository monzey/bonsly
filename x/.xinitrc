feh --bg-scale ~/wall

xset +fp ~/.fonts
xset fp rehash

setxkbmap fr
setxkbmap -option ctrl:swapcaps

xrdb -merge ~/.Xresources

[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xmodmap -e "keycode 62 = Escape"

exec dbus-launch i3
