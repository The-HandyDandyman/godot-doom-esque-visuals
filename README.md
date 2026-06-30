Hello! My name's Dandy, and I'm somebody who likes programming and has been working on a project inspired by old, cheap, 3D first person PC games! 
Due to this, the commitment to authenticity for that aforementioned project and the fact I have a feeling there are more people besides I who are probably interested in that sort of niche:
I've made this open source Github repo packaged with the shaders I use and some
stock assets seperate from my original project, specifically to act as a way to both share what I've managed to start so far and as a way to hopefully get assistance on specific aspects!


![alt text](https://raw.githubusercontent.com/The-HandyDandyman/godot-doom-esque-visuals/refs/heads/main/godotDoomesqueVisualsPreview.png "Wacky preview")

-- What's included? --

- My improved multi-directional sprite shader, which includes the ability to adjust the amount of directions and animation frames, the ability for asymmetry, the ability to scale,
Y-billboarding and the ability to modulate! If you'd like more info, check the credits and read the instructions in the link!

- Several public Godot shaders I've used for the project: particularly, tetrabrobpy's N64 Sky, ALT_OhDude's adapt-to-paletete shader, and what (from what I remember) a modified version of
the palette swap technique used by Ombarus on Youtube.

- Some sample textures, mostly modified from OpenGameArt and Wikimedia Commons with a custom demonstration spritesheet for the directional shader
using APirateHat's Godot Plushie model!

- A modified version of a test map I had been using in the unrelated personal project that served as part of the reason I created this repo.

-- What am I seeking to include in the future? --

- The big one at the moment is sector-based lighting: I've opened a thread on the Godot Forums you can find at this link
( https://forum.godotengine.org/t/seeking-advice-regarding-attempts-to-replicate-the-behavior-of-doom-style-lighting/139445 )
to discuss the matter and try and figure out a good way to implement that sort of system,
though at the moment I'm currently experimenting to see what methods would work best for the kind of technique I'm trying to replicate.


-----
Assets included and credits:

[  Multi-Directional Sprite Shader -- https://godotshaders.com/shader/multi-directional-sprite-shader/  

Built off an open source shader I found 3 years ago by Reddit user dron1885. If you need any instructions, I'd recommend reading the link above!
Initial adjustments by Dandy (that's me!) and tentabrobpy on Godot Shaders ]

[ N64 Sky Shader (a lot of old PC games use a sky texture akin to this!] - https://godotshaders.com/shader/n64-style-skybox/ 
 
   Shader by tentabrobpy on Godot Shaders ]

[ Adapt to Palette Shader - https://godotshaders.com/shader/adapt-to-palette/ 

 Shader by ALT_OhDude on Godot Shaders ]

[ Godot Plushie Spritesheet: Created using this model by APirateHat on Itch.io https://apiratehat.itch.io/godot-plushie-3d-character . Sprites were made with Libresprite and applying the palette used via Indexed Dither mode.]

[ Screen Palette Swap Shader
 Works both for palette swapping the whole screen and for "glitchy corrupted" colors if you need those. Built off this shader by Badger_ on the Godot Shaders website: https://godotshaders.com/shader/palette-swap-post-process-image-parametrized/]

[ Rest of the graphical assets are created from stock images pulled from OpenGameArt and Wikimedia Commons ]

[ PALETTE.png is directly pulled from the PLAYPAL found in Sonic Robo Blast 2 and Dr. Robotnik's Ring Racers. ]

[ PALETTESWAPTEST.png is directly pulled from the PLAYPAL found in maxwellCleanColors, a SRB2 mod that you can find here: https://mb.srb2.org/addons/maxwellcleancolors-a-palette-mod.5754/. ]

[PixelOperator font comes from https://www.dafont.com/pixel-operator.font )
