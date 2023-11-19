# Time's Up!! 2600
Simple reaction game of finite length. 
* To start the game, press the up arrow
* After a delay, another arrow appears on screen and time starts counting down
* Press the joystick in the direction indicated by the arrow
* Correct reaction scores a point and stops the clock until the next arrow
* Incorrect reaction leaves the clock running until the next arrow
* After a short random delay a new arrow appears
* When time reaches 0 the game is over
* After roughly half the time has elapsed, the arrow positions become random
* Time unit is screen cycles (60/second)
  * Before the game starts, use the select button to add time (max 2500)
  * Delay between arrows is random between 16 and 127 cycles

# Try it:
Play here: [timesup (javatari)](https://javatari.org/?ROM=https://kismographic.binaryj.net/roms/timesup.bin)

## TODO
* Make the icons larger
* Add github actions to build and publish
* Add sound
  * buzz for error
  * nice sound for correct
  * neutral sound when icon pops
* Game controls:
  * difficulty - disable random position?
* Modes/switches:
  * position
    * fixed/correlated
    * fixed/uncorrelated
    * random
