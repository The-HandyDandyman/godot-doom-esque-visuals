Hello! My name's Dandy, and I'm somebody who likes programming and has been working on a project inspired by old, cheap, 3D first person PC games! 
Due to this, the commitment to authenticity for that aforementioned project and the fact I have a feeling there are more people besides I who are probably interested in that sort of niche:
I've made this open source Github repo packaged with the shaders I use and some
stock assets seperate from my original project, specifically to act as a way to both share what I've managed to start so far and as a way to hopefully get assistance on specific aspects!


![alt text](https://raw.githubusercontent.com/The-HandyDandyman/godot-doom-esque-visuals/refs/heads/main/godotDoomesqueVisualsPreview.png "Wacky preview")

-- What's included? --

- My improved multi-directional sprite shader built off of the original more primtive shader by dron1885 on Reddit, which now includes the ability to adjust the amount of directions and animation frames, the ability for asymmetry, the ability to scale,
Y-billboarding and the ability to modulate! If you'd like more info, check the credits and read the instructions in the link!

- A modified triplanar texture shader based on the one by Soup-o-Stat which is designed to give you options for culling, flip textures if the culling is off or the textures just don't render on the right side, along with the ability to rotate and offset the texture! Also allows for masks and overlays which can also be adjusted to fit your needs, dithered transparency with a customizable dither texture to suit whatever dither pattern fits your needs most!

- tetrabrobpy's N64 Sky, with very minimal alteration to add a transparent toggle which discards transparent pixels! You can use that in order to make layered skies!
- ALT_OhDude's adapt-to-paletete shader.. mostly unaltered, if it ain't broke, don't fix it!

- A modified screen palette shader based on the one by Badger_ on Godot Shaders, which allows you to both palette swap the whole screen after applying the adapt-to-palette shader first and to offset the colors!

- Some sample textures, mostly modified from OpenGameArt and Wikimedia Commons with a custom demonstration spritesheet for the directional shader
using APirateHat's Godot Plushie model!

- Flat warping for triplanars (akin to Quake's fluid distortion!), though not a particularly accurate thing for vanilla Doom it is present in many source ports (ZDoom and GZDoom!)
  
- Proper lightmaps, with the ability to change a sprite's solid color and to affect the surroundings!

- This is more of a Baldi thing than a Doom thing, but since I reckoned it might be practical: sprites and triplanars both support light masks which mask out the lightmap and give the illusion of illumination!

 - Light diminishing and fog which can be controlled by shader globals, with optional color banding and most of the adjustment settings fog_depth has! By default, this uses -VERTEX.Z which makes the fog linear, though there is an option for radial fog!

- A modified version of a test map I had been using in the unrelated personal project that served as part of the reason I created this repo.

- A simple transition manager with a screen melt shader transition attached to it using a modified version of ericalfaro's Pixel Melt shader!

- Stock music from Microsoft Music Producer (wouldn't recommend using the audio or the midi outside of the sample project here)

-- What am I seeking to include in the future? --

- Lighting setup is nearly complete, though there are a few caveats to work around! To name a few:
- 
- I need to implement some way to create viewporttexture-based lightmaps, allowing them to be updated when needed and to make creating them a lot more practical.
- Though not a top priority at the moment + not necessary for all cases: I would like to figure out a way to account for the Y axis in the lightmaps. I'm unsure of how I'd go about this, but especially when accounting for Doom's floor-over-floors and how they can have different levels of light between them, I reckon that is something I ought to figure out!
- 
- I'd like to adjust the light diminishing, as I have noticed in some spots within both Doom and some of the games built off it (mainly, srb2) that despite the fact that the game uses light diminishing for the most part, there are spots where light diminishing is seemingly either absent or lowered immensely. I'd like to look into how that's handled!

- I may try and find a way to make the directional sprite shader work with Sprite3Ds, at the moment you kind of have to measure them based on other sprites as they use MeshInstance3Ds though I hope to remedy that issue in the future. At the moment, it's not really necessary but it would make the difference between handling directional sprites and static sprites a littleee less jarring.


-----
Assets included and credits:

[  Multi-Directional Sprite Shader -- https://godotshaders.com/shader/multi-directional-sprite-shader/  

Built off an open source shader I found 3 years ago by Reddit user dron1885. If you need any instructions, I'd recommend reading the link above!
Initial adjustments by Dandy (that's me!) and tentabrobpy on Godot Shaders ]

[ N64 Sky Shader (a lot of old PC games use a sky texture akin to this!] - https://godotshaders.com/shader/n64-style-skybox/ 
 
   Shader by tentabrobpy on Godot Shaders ]

[ Adapt to Palette Shader - https://godotshaders.com/shader/adapt-to-palette/ 

 Shader by ALT_OhDude on Godot Shaders ]

[ Screen Palette Swap Shader - https://godotshaders.com/shader/palette-swap-post-process-image-parametrized/

   Original Shader by Badger_ on Godot Shaders, Extra Adjustments by Dandy ]

[ Triplanar Texture Shader - https://github.com/Soup-o-Stat/Triplanar-Texture-Shader

   Original Shader by Soup-o-Stat on Github, Extra Adjustments by Dandy ]

[ Transparency Dither Shader - https://godotshaders.com/shader/transparency-dither/ 

  Created by jacob on Godot Shaders, used partially for the dithered transparency (specifically for the transparency part) ]
    
[ General Dither Shader - https://sambigos.itch.io/godot-dither-shader

   Created by sam.bigos on Itch.io, used partially for the dithered transparency (specifically the customizable dither pattern) ]

[ Adobe Animate Screen Blend Function - https://godotshaders.com/shader/adobe-animate-blend-modes/

   Created by cherrythecool on Godot Shaders, used to help create the light masks used alongside the lightmaps]

[ Lightmap Implementation - https://forum.godotengine.org/t/seeking-advice-regarding-attempts-to-replicate-the-behavior-of-doom-style-sector-lighting/139445 
               Implemented by Dandy, additional pointers and help from normalized on the Godot Forums ]

[ Light Diminishing - https://medium.com/@jmickle_/writing-a-doom-style-shader-for-unity-63fa13678634 
         Implemented by Dandy, loosely based upon the implementation of it in Unity from Jazz Mickle at Medium ]

[ Quake-style Fluid/Z-Doom Flat Warping - https://godotshaders.com/shader/quake-style-fluid/
                          Original shader by kureca8 on Godot Shaders ]

[ Godot Plushie Spritesheet: Created using this model by APirateHat on Itch.io https://apiratehat.itch.io/godot-plushie-3d-character . Sprites were made with Libresprite and applying the palette used via Indexed Dither mode.]

[ Pixel Melt Shader - https://godotshaders.com/shader/pixel-melt/

   Created by ericalfaro on Godot Shaders]

[ Rest of the graphical assets are created from stock images pulled from OpenGameArt and Wikimedia Commons ]

[ PALETTE.png is directly pulled from the PLAYPAL found in Sonic Robo Blast 2 and Dr. Robotnik's Ring Racers. ]

[ PALETTESWAPTEST.png is directly pulled from the PLAYPAL found in maxwellCleanColors, a SRB2 mod that you can find here: https://mb.srb2.org/addons/maxwellcleancolors-a-palette-mod.5754/. ]

[PixelOperator font comes from https://www.dafont.com/pixel-operator.font )
