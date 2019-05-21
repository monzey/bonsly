feh --bg-scale ~/wall.png

xset +fp ~/.fonts
xset fp rehash

setxkbmap fr
setxkbmap -option ctrl:swapcaps

xrdb -merge ~/.Xresources

[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xmodmap -e "keycode 62 = Escape"

wal -R

mopidy

exec i3
