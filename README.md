# 45-allow-colord.pkla

https://www.reddit.com/r/Ubuntu/comments/15stmwn/how_do_i_suppress_authentication_is_required_to/

```bash
    6  xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
    9  xrandr --addmode DUMMY0 1920x1080_60.00
   10  xrandr --output DUMMY0 --mode 1920x1080_60.00
```
