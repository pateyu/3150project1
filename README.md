# 3150project1

hungfeature.asm was added, not tested, this is assigned on PINA3, which increments the counter on a timer and plays a sound based on the number on the counter, I do not have the board so I am unable to this if this is fully functional, sound frequency and interval and when they are outputted need to be changed, it only has sounds for the first 3 values, this also checks if PINA2 if ever pressed then program will be interrupted and resetted

main.asm was added 2 new subroutines, the decrement and clear, PINA1 decrements the counter, PINA2 clears the counter

main.asm at some point should have all features added to it and all other functionalities should be on different PIN in order to call upon our features, pretty sure this is the "menu" we're supposed to have