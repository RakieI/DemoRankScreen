# DemoRankScreen
Shows rankings during Demo Mode.

> Last tested on Ikemen GO v0.99 and Nightly Build (2025-09-18)  
> Module developed by Rakíel

Ikemen GO module to show rankings during Demo Mode, like some games do.

# Installation

1. Extract the archive contents into the "./external/mods" directory.  
2. Add your settings under [HiScore Info] in `system.def`.

# DemoRankScreen parameters

- demo.ranking.enabled:  
  - Set to 1 to enable rankings during Demo Mode.(Default is 0)  
- demo.ranking.portraits:  
  - Set to 1 to show portraits in the ranking.(Default is 1)
- demo.ranking.waittime:  
  - The delay (in frames) after Demo Mode starts before showing the Rankings.  
- demo.ranking.endtime:  
  - How long the ranking stays on screen.

# Example
```ini
[Hiscore Info]
demo.ranking.enabled = 1
demo.ranking.portraits = 1
demo.ranking.waittime = 400
demo.ranking.endtime = 500
```

The mod looks for all available rankings, including custom modes, and chooses one to display on the screen each time Demo Mode starts. This way, you can see a different ranking
every time, as long as you have them saved—not just the Arcade Mode.