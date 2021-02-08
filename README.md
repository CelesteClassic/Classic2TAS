# Instructions to run 
download LOVE from https://www.love2d.org/
in the directory of the project, run 
``` <path to your love executable> . <cartname>``` 
where cartname is the name of the cart you want to TAS which should be in the carts folder. if cartname is omitted, celeste2_1.1.p8 will be loaded

# Usage
First of all, you will see a timer in the top-left corner, which tracks the time, and a black rectangle right next to it, the black rectangle is an input viewer, where you can see what keys are being pressed on that frame. The input viewer will be blacked out because you can't input anything yet, as you are in the spawning state, once the spawning state is over (around 26 frames after loading the level, depends on the level) you will be able to see the keys.

Each time you press a key (up, down, right, left, x, c, or z) that key will toggle on/off for that frame.

To go to the next level press F and to go to the previous level press S, note that this will reset the inputs.

To step forward in time press L, which will advance the game one frame, and the keys that were inputted for that frame will be executed. if you're advancing to that frame for the first time, the inputs for it will be duplicated from the last frame

To step backwards in time press K, which will step 1 frame backwards, and you can change what was pressed before.

To see the TAS in real time press P, which will start reproducing the inputs from the frame you are currently on. (Note: you shouldn't input anything while the TAS is reproducing)

To go back to the first frame press D, which will restart the game but still keep your inputs.

To reload the level and delete your inputs press R.

To hide/unhide the timer and input viewer press E.

To save a clean version of the TAS press U, which will playback the tas, then automatically create a file called 'TAS1.tas' (replacing the 1 with the level number you are on) in the love2d folder (check the [love2d page](https://love2d.org/wiki/love.filesystem) for more information), or check the console message that appears when you save the TAS, which specifies the directory it gets saved to.
this can be interrupted at any time by pressing P. 
Note: a clean version will only be saved if the level can be finished. If it can't (because of an incomplete TAS, etc.) only a raw version will be saved

To save a raw version of the TAS press M, which will save the file in the same place as U, but it won't cut off inputs after the end of the level. it is recommended you use this only for saving WIP TASes

To open a TAS file, simply drag the file into the window, note that this won't change the current state of the game, so you should always press D after loading a file.
alternatively, pressing w will load the relevant file from a folder named TAS in your love2d folder

Press Y to see the current position, rem values (sub-pixels) and speed of the player on the console.

To reproduce a full game TAS, create a folder named 'TAS' inside the love2d folder, inside this folder there should be a TAS file for each level, named TAS1, TAS2, ...., TAS8 and to reproduce it press N.

You can press F1 or F6 to save a screenshot, F3 or F8 to start a recording and F4 or F9 to save the recording, both saved to the love2d folder, and the console output will show what that directory is.

# TAS Database 
https://celesteclassic.github.io/tasdatabase/
