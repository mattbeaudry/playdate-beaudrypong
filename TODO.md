# TODO

## TODO FEATURES
- smash wind up meter
	- UI gauge
	- make it count for how fast the smash is
	- better animation or particle effect for swing AND hit
- better sound and theme music
- coworker ai improvement
	- coworker spinCalc is perfect every time because the ai just follows the y position of the ball
	- not perfect swing every time
	- don't follow ball.y perfectly
	- move up/down before serving
	- coworker can smash
- office environment movement animation
	- server light flash
	- boss getting up crossing arms from time to time, maybe during a smash windup? 
	- 2 frame animation for each desk employee+state
	- player/coworker stance bounce
- cutscene transitions between rounds
	- current player leaves and desks get trashed
	- then new player walks up to dialog standing area
- tutorial or better how to
	
## TODO FIXES
- dialog box width and leading space bug
- tweak spin calc sensitivity so gameplay is decent
- only can smash when gauge full
- higher serve throw
- move more code out of main file
- remove unneeded boss class
- ball pauses in thin air once a point is made, after point ball logic, it should roll off screen
- player should be holding ball at beginning of his serve
- stats are catering too long rallies in rounds

## COMPLETE FEATURES
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
	- game time speed
	- opponent: [player, boss, coworker, designer, pm]
	- skill level of coworker AI
	- score for each round and score board
	- speed is faster per round
- pre round dialog --> support back and forth, multiple pieces of text, back and forth with player, use which ever character you are about to play instead of the boss every time
- better dialog system
	- better box style
	- move box depending on which character is talking
- miss/poor/good/great/perfect onscreen labels for shot accuracy feedback
- hi score board
- game stats: smashes, how long the rallies were, missed swings, swing accuracy etc.
- saving hi scores
- viewing hi scores
- stats on endScree
	
## COMPLETE FIXES
- bug fixes / refactoring
- coworker graphics alignment when swinging etc.
- player swinging messes up coworker while serving
- desk sprite overlay bug
- coworker serve swing takes into account round timeSpeed for swing timing
- make the spin logic make more sense, instead of above and below, how about closer to middle more spin toward other player
- coworker not flying off screen when hit with smash
- game glitches after smash, multiple rounds happen quickly, point doesn't go to player
- when player throw a serve but doesn't swing, they should lose a point
- sometimes coworker or player server throw goes up too high
- things don't reset properly after playing a game and starting a second game
- improved desk graphics for server developers - missing trashed sprites

# IDEAS
- what if boss doesn't have a paddle and just hits the ball with his hand
- use the crank, maybe a "super smash" that requires it
	- crank to aim smash? crank to dodge a coworkers smash
- what if crank was the vertical position of the player
