# Actions On Button Press

These scripts allow players on the server to press a button (displayed on screen) to trigger a function.  
Note that if you combine several scripts you will have to change the texts positions so that they don't overlap by changing the last value in `setPoint()`  
You can also change the text's position in `setPoint()` and the size and font type in `createServerFontString()`  

Changing the button in `Init()` will change both the button displayed on screen and the button used to trigger the function.  
Here is a non-exhaustive list of buttons you can use  
```
"+usereload"
"weapnext"
"+gostand"
"+melee"
"+actionslot 1"
"+actionslot 2"
"+actionslot 3"
"+actionslot 4"
"+actionslot 5"
"+actionslot 6"
"+actionslot 7"
"+frag"
"+smoke"
"+attack"
"+speed_throw"
"+stance"
"+breathe_sprint"
```

## suicide_on_button_press.gsc

The player dies when pressing the button

## camera_switch_vote_on_button_press.gsc

Allows the players to toggle their vote to change the `camera_thirdPerson` dvar on the server (players vote no by default)  
When enough players vote yes the server changes the dvar and resets the vote counts.  
The amount of votes required is more than 50% of the players: 1/1 | 2/2 | 3/4 | 3/5 | 4/6 etc.  
Bots are ignored for the votes.
