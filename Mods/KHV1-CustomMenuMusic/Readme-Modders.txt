If you're reading this, please be aware this is info for modders. If you're wondering how to install it, then the answer is the same way as any other modlet (The folder called KHA21-CustomMenuMusic should be in 7 Days to Die/Mods or %appdata%/Roaming/7DaysToDie/Mods).

Right... modders.

If you want to change the menu music to your own, then you need to do the following.

- Create a new unity project. I did it in Unity 2021.3.25f1.
- Make a folder called scripts. Copy MultiPlatformExportAssetBundles.cs into that folder.
- Copy the music you want to use into your unity project. I found .WAV works best.
- Rename the music file to new_menu_music_lp (exactly this).
- Right-click it and select "Build Multi-Platform AssetBundle From Selection".
- Name the bundle MenuMusic.unity3d (exactly this).
- Copy the new bundle into KHA21-CustomMenuMusic/Assets and overwrite. You're done!