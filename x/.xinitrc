feh --bg-scale ~/wall.png

xset +fp ~/.fonts
xset fp rehash

setxkbmap fr
setxkbmap -option ctrl:swapcaps

xrdb  ~/.Xresources

[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

wal -R

exec i3
