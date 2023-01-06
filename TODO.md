# TODO
- round of bug fixes
	- player swinging messes up coworker while serving
	- only can smash when gauge full
	- end screen score fix
	- coworker graphics alignment when swinging etc.
	- coworker not flying off screen when hit with smash
	- speed is faster per round
- make the spin logic make more sense, instead of above and below, how about closer to middle more sprint toward other player
- improve smash wind up meter
- score for each round and score board
- coworker can smash
- move more code out of main file
- office environment movement animation:
	- server light flash
	- boss getting up crossing arms from time to time
	- 2 frame animation for each desk employee+state
	- player/coworker stance bounce
- epic move POWERSMASH that requires a pause and cinematic animation and requires using the crank to do a smash
	- the whole office, desks, employees etc should be swallowed up in the power of the power smash
	- maybe this is how you win the game

# DONE
- player, table, ball and coworker graphics
- player swing and serve
- ball movement physics and logic
- rallying with coworker
- background graphics
- office desk system: 3 types (coworker, developer, boss, server) that can be occupied, afk or trashed
- smash
	- player smash meter is full so they can smash
	- hold B to charge and release to smash
	- * ball goes straight towards other player at speed depending on windup
	- if opponent gets hit they fly off screen
- coworker serve functionality
	- ball should go into coworker or player hand depending on who won last point
- logo + preview banner
- dialog system
- rounds class for diff rounds of the game, data includes:
	- pre-round dialog between boss and developer
	- game timespeed
	- opponent: [player, boss, coworker, designer, pm]
	- skill level of coworker AI

# IDEAS
- what if boss doesn't have a paddle and just hits the ball with his hand