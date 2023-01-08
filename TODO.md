# TODO

## TODO ALPHA
- make the spin logic make more sense, instead of above and below, how about closer to middle more spin toward other player - make player swing indicator be right where paddle is when swinging
- only can smash when gauge full
- bug fixes
	- coworker not flying off screen when hit with smash
	- game glitches after smash, multiple rounds happen quickly, point doesn't go to player
	- when player throw a serve but doesn't swing, they should lose a point
- hi score board

## TODO RELEASE
- pre round dialog --> support back and forth, multiple pieces of text, back and forth with player, use which ever character you are about to play instead of the boss every time, still see boss at beginning
- clean up how to and intro screen
- improve smash wind up meter and make it count for how fast the smash is
- coworker can smash
- office environment movement animation:
	- server light flash
	- boss getting up crossing arms from time to time
	- 2 frame animation for each desk employee+state
	- player/coworker stance bounce
- move more code out of main file
- better sound

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
	- score for each round and score board
	- speed is faster per round
- bug fixes
	- coworker graphics alignment when swinging etc.
	- player swinging messes up coworker while serving
	- desk sprite overlay bug
	- coworker serve swing takes into account round timeSpeed for swing timing

# IDEAS
- what if boss doesn't have a paddle and just hits the ball with his hand