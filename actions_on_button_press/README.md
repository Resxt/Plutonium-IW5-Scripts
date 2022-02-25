# Actions On Button Press

This script shows how you can execute functions and change dvars for a player when that player presses a certain button while showing him instructions on his screen using the key defined in his game.

If you use `+melee` and the player's melee key is set to V it'll show V on his screen, if he uses another key it'll show his key.

* The first button  lets the player toggle the `camera_thirdPerson` dvar (used to play in third person while keeping the crosshair on and is also better/more configurable than `cg_thirdPerson` in my opinion)
Note that `camera_thirdPerson` is a special case and needs to be changed with `SetDynamicDvar()` but in most cases like with `cg_thirdPerson` you'd use `SetDvar()` instead.

* The second button lets the player suicide using the `Suicide()` function.

If you want to use another button simply change `level.third_person_button` and/or `level.suicide_button` values and it will update the button pressed to start the function and the text displayed on the player's screen.

I used actionslot 6 and 7 because (to my knowledge) they are not used by anything else in the game
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