//
//  Gameplay.m
//  dereknetto
//
//  Created by Z on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameConstants.h"
#import "Gameplay.h"
#import "Star.h"
#import "Enemy.h"
#import "Avatar.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"
#import "DerekNumber.h"
#import "CCActionMoveToNode.h"

@implementation Gameplay {
    
    CMMotionManager *_motionManager; //create only one instance of a motion manager
    Avatar *_character;
    
    CCPhysicsNode *_physicsNode;
    CCParticleSystem *_blueSparks;
    CCParticleSystem *_starSparks;
    
    NSMutableArray *starArray;
    NSMutableArray *enemyArray;
    NSMutableArray *achievementArray;
    
    CCNode *_gameOverMenu;
    CCNode *_pausedNode;
    
    CCNode *_tiltcommand;
    
    CCButton *_restartButton;
    CCButton *_backToMainButton;
    
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_gameTimeLabel;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_comboCountLabel;
    CCLabelTTF *_roundScoreLabel;
    CCLabelTTF *_highScoreLabel;
    
    BOOL paused;
    BOOL _gameOver;
    BOOL isMovingClockwise;
    BOOL isMovingClockwiseOld;
    
    NSMutableArray *rotationArray;
    CCNodeColor *_timeBar;
    
    int score;
    int comboCount;
    int crushAmmo;
    
    float time;
    float totalTime;
    float gameTime;
}

- (void)didLoadFromCCB {
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.collisionDelegate = self;
    
    // visualize physics bodies & joints
    // _physicsNode.debugDraw = TRUE;
    
    _comboCountLabel.visible = FALSE;
    
    //restart button is invisible at start
    _restartButton.visible = FALSE;
    _gameOverMenu.visible = FALSE;
    
    _gameOver = FALSE;
    paused = FALSE;
    _pausedNode.visible = FALSE;
    _backToMainButton.visible = FALSE;
    
    //make sure paused shows on top of stuff
    _pausedNode.zOrder = 200;
    _restartButton.zOrder = 200;
    _backToMainButton.zOrder = 200;
    _scoreLabel.zOrder = 200;
    _timeBar.zOrder = 1;
    _scoreLabel.zOrder = 200;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

#pragma mark - Tilt Methods

- (id)init
{
    if (self = [super init])
    {
        _motionManager = [[CMMotionManager alloc] init];
        self.lastUpdateTime = [[NSDate alloc] init];
        
        starArray = [NSMutableArray array];
        enemyArray = [NSMutableArray array];
        rotationArray = [NSMutableArray array];
        
        achievementArray = [NSMutableArray array];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [_motionManager startAccelerometerUpdates];
    
    score =0;
    gameTime =0;
    comboCount =0;
    crushAmmo = 0;
    
    //reset
    MAX_ENEMIES = 1;
    enemySpeed = 100;
    
    //preload sounds
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playBg:@"gamesounds/space ambient.m4a" volume:0.5 pan:0 loop:TRUE];
    
    [audio preloadEffect:@"gamesounds/AvatarSpawn.wav"];
    [audio preloadEffect:@"gamesounds/AvatarDeath.wav"];
    [audio preloadEffect:@"gamesounds/YellowPower.wav"];
    [audio preloadEffect:@"gamesounds/EnemyKill.wav"];
    
    [audio preloadEffect:@"gamesounds/RedSpawn.wav"];
    [audio preloadEffect:@"gamesounds/GreenSpawn.wav"];
    [audio preloadEffect:@"gamesounds/PinkSpawn.wav"];
    [audio preloadEffect:@"gamesounds/StrawberrySpawn.wav"];
    
    [audio preloadEffect:@"gamesounds/StarGet.wav"];
    [audio preloadEffect:@"gamesounds/StarMiss.wav"];
    
    [audio preloadEffect:@"gamesounds/GameOver.wav"];
    
    //sets the default time for game
    time = defaultTime;
    totalTime = time;
    
    //adds character
    [self addAvatarInitial];
    _blueSparks.visible= YES;
    _starSparks.visible = NO;
    
    //adds first star
    [self addStar];
    
    //adds first enemey
    [self addEnemy];
    
    [[_tiltcommand animationManager] runAnimationsForSequenceNamed:@"tilt move"];
    
}
- (void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

# pragma mark - Update method
- (void)update:(CCTime)delta {
    
    if (paused == FALSE) {
        CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        //define movement variables
        CGFloat newXPosition = _character.position.x - acceleration.y * speedMultiplier * delta;
        CGFloat newYPosition = _character.position.y + acceleration.x * speedMultiplier * delta + Y_offset;
        newXPosition = clampf(newXPosition, 0, self.boundingBox.size.width);
        newYPosition = clampf(newYPosition, 0, self.boundingBox.size.height);
        
        //define rotation variables
        float angleOfMovement = ccpAngle(ccp(0, 1), ccpSub(ccp(newXPosition, newYPosition), _character.position)); // in radians
        float angleOfMovementInDeg = CC_RADIANS_TO_DEGREES(angleOfMovement);
        
        if (_character.position.x - newXPosition > 0) {
            if (newYPosition - _character.position.y < 0) {
                angleOfMovementInDeg = 360 - angleOfMovementInDeg;
            } else {
                angleOfMovementInDeg = -angleOfMovementInDeg;
            }
        }
        
        while (angleOfMovementInDeg > 360) {
            angleOfMovementInDeg -= 360;
        }
        while (angleOfMovementInDeg < 0) {
            angleOfMovementInDeg += 360;
        }
        
        if (angleOfMovementInDeg == angleOfMovementInDeg) {
            _character.rotation = angleOfMovementInDeg;
        }
        
        BOOL isMovingClockwiseNew = (_character.rotation - angleOfMovementInDeg) > 0;
        
        //record last position in order to calculate appropriate rotation
        float lastX =_character.position.x;
        float lastY =_character.position.y;
        
        //move avatar
        _character.position = CGPointMake(newXPosition, newYPosition);
        
        //calculate distance avatar has moved since last update
        float diffx = _character.position.x - lastX;
        float diffy = _character.position.y - lastY;
        
        //set threshold for rotation to avoid jittering
        float squareDistance = ((diffx*diffx) + (diffy*diffy));
        if(squareDistance >= deadZone)
        {
            
            if (isMovingClockwiseNew == isMovingClockwise && isMovingClockwise==isMovingClockwiseOld) {
                
            }
            isMovingClockwiseOld = isMovingClockwise;
            
            isMovingClockwise = isMovingClockwiseNew;
        }
        
        // decreases the time remaining every update cycle
        time -= delta;
        _timeLabel.string = [NSString stringWithFormat:@"%.0f", fabsf(ceil(time))];
        _timeBar.scaleX = time/totalTime;
        
        //makes game end if timer runs out
        if ((time < 0 && !_gameOver) || _gameOver) {
            _gameOver= TRUE;
            [self gameOver];
        }
        
        // increments the lifetime of stars
        for (int i=0; i < starArray.count; i++) {
            Star* _currentStar = ((Star*)starArray[i]);
            _currentStar.lifetime +=delta;
            
            if (_currentStar.lifetime > starLife) {
                [self starDeath:_currentStar];
                [self addStar];
            }
        }
        
        for (Star *s in starArray) {
            // float rotateAmount = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 5.0f + 1);
            ((Star*)s).rotation += 5;
        }
        
        // increments the lifetime of enemies
        for (int i=0; i < enemyArray.count; i++) {
            Enemy* _currentEnemy = ((Enemy*)enemyArray[i]);
            _currentEnemy.lifetime +=delta;
            
            if(_currentEnemy.lifetime > enemyLife) {
                [self enemyRemoved:_currentEnemy];
            }
        }
        
        int randomDelay = arc4random_uniform(85)+1;
        if ((randomDelay % 60) == 0) {
            [self addEnemy];
        } else if (enemyArray.count == 0) {
            [self addEnemy];
        }
        
        //increment game time
        gameTime = gameTime + 1;
        float gameTimeInSec = gameTime/60;
        _gameTimeLabel.string = [NSString stringWithFormat:@"%.0f", fabsf(ceil(gameTimeInSec))];
        
    }
}

#pragma mark - Collision with Star

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair avatar:(CCNode *)nodeA star:(Star *)collidedStar {
    
    // removes star on collision with avatar
    [self starCollisionRemoved:collidedStar];
    
    //play sound
    [[OALSimpleAudio sharedInstance] playEffect:@"gamesounds/StarGet.wav"];
    
    //updates the score
    score++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", score];
    
    //increase time
    time = time + (starLife - collidedStar.lifetime) + 3;
    if (time>totalTime){
        time = totalTime;
    }
    _timeLabel.string = [NSString stringWithFormat:@"%f", time];
    
    //adds next star
    if (starArray.count == 0){
        [self addStar];
    }
    
    return NO;
}

#pragma mark - Collision with Enemy

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair avatar:(CCNode *)nodeA enemy:(CCNode *)nodeB {
    if ((comboCount >=5) || (crushAmmo >= 1)){
        [self enemyRemoved:nodeB];
        --crushAmmo;
        
        //play sound
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:@"gamesounds/EnemyKill.wav"];
        
        if (crushAmmo == 0){
            [_character setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"LollyFolder/PinkLolly.png"]];
            _blueSparks.visible = YES;
            _starSparks.visible= NO;
        }
    }
    else{
        [self avatarRemoved:nodeA];
        _gameOver = TRUE;
    }
    return NO;
}

#pragma mark - Removal Methods

-(void) avatarRemoved: (CCNode *)avatar {
    
    //load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"AvatarExplosion"];
    
    //make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    
    //place the particle effect on the avatar's position
    explosion.position = avatar.position;
    
    //add the particle effect to the same node the avatar is on
    [avatar.parent addChild: explosion];
    
    //play death sound
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"gamesounds/AvatarDeath.wav"];
    
    //remove the avatar
    _character.visible = FALSE;
}

-(void) starCollisionRemoved: (CCNode *)star {
    
    //load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarExplosionStars"];
    
    //make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    
    //place the particle effect on the star's position
    explosion.position = star.position;
    
    //add the particle effect to the same node the star is on
    [star.parent addChild: explosion];
    
    //finally, remove the collected star
    [starArray removeObject: star];
    [star removeFromParent];
    
    //increase combo count
    comboCount++;
    _comboCountLabel.string = [NSString stringWithFormat:@"%d", comboCount];
    
    //gain 1 crush ammo for every 3 star combo
    if ((comboCount % 5 == 0) && (comboCount != 0)){
        crushAmmo++;
    }

    if ((comboCount == 5) && (crushAmmo ==1)) {
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:@"gamesounds/YellowPower.wav"];
    }
    if (crushAmmo >=1){
        [_character setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"LollyFolder/YellowLolly.png"]];
        _blueSparks.visible=NO;
        _starSparks.visible =YES;
    }
    
    //adjust game difficulty as score increases
    if ((score != 0) && (score <= 200)){
        
        if ((fmodf(score,40)) == 0){
            MAX_ENEMIES = MAX_ENEMIES + 1;
        }
        if ((fmodf(score,10)) == 0){
            enemySpeed = enemySpeed + 5;
        }
    }
}

-(void) starDeath: (CCNode *)star {
    
    //load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarDeath"];
    
    //make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    
    //place the particle effect on the star's position
    explosion.position = star.position;
    
    //add the particle effect to the same node the star is on
    [star.parent addChild: explosion];
    
    //play sound
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"gamesounds/StarMiss.wav"];
    
    //finally, remove the collected star
    [starArray removeObject: star];
    [star removeFromParent];
    
    //reset combo count
    comboCount = 0;
    _comboCountLabel.string = [NSString stringWithFormat:@"%d", comboCount];
}

-(void) enemyRemoved: (CCNode *)enemy {
    
    //load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"EnemyRemovedParticle"];
    
    //make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    
    //place the particle effect on the enemy's position
    explosion.position = enemy.position;
    
    //add the particle effect to the same node the enemy is on
    [enemy.parent addChild: explosion];
    
    //finally, remove the enemy
    [enemyArray removeObject: enemy];
    [enemy removeFromParent];
    
}

#pragma mark - add methods

-(void) addAvatarInitial {
    
    // create a character from the ccb-file
    _character = (Avatar*)[CCBReader load:@"Avatar" owner:self];
    
    // spawn character in middle of screen
    _character.position = ccp(self.boundingBox.size.width/2, self.boundingBox.size.height/2);
    
    // add new avatar to the physics world
    [_physicsNode addChild:_character];
    
    //play sound
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"gamesounds/AvatarSpawn.wav"];
    
    _character.zOrder =5;
    
}

-(void) addStar {
    
    if (starArray.count < MAX_STARS) {
        
        // create a star from the ccb-file
        Star *_currentStar;
        _currentStar = (Star*)[CCBReader load:@"Star"];
        
        //add star to array
        [starArray addObject:_currentStar];
        
        // make sure new star doesnt spawn on enemies
        CGSize screenSize = [[CCDirector sharedDirector] viewSize];
        BOOL starEnemyIntersect = TRUE;
        BOOL oldStarEnemyIntersect;
        if (enemyArray.count !=0){
            
            while ((starEnemyIntersect) || (oldStarEnemyIntersect)) {
                _currentStar.position = ccp(arc4random_uniform(screenSize.width), arc4random_uniform(screenSize.height));
                
                for (int i=0; i < starArray.count; i++) {
                    Star* _currentStar = ((Star*)starArray[i]);
                    CGRect absoluteStarBox = CGRectMake([_currentStar boundingBox].origin.x, [_currentStar boundingBox].origin.y, [_currentStar boundingBox].size.width, [_currentStar boundingBox].size.height);
                    
                    oldStarEnemyIntersect = FALSE;
                    for (int i=0; i < enemyArray.count; i++) {
                        Enemy* _spawnedEnemy = ((Enemy*)enemyArray[i]);
                        
                        CGRect absoluteSpawnedEnemyBox = CGRectMake([_spawnedEnemy boundingBox].origin.x, [_spawnedEnemy boundingBox].origin.y, [_spawnedEnemy boundingBox].size.width, [_spawnedEnemy boundingBox].size.height);
                        
                        starEnemyIntersect = CGRectIntersectsRect(absoluteSpawnedEnemyBox, absoluteStarBox);
                        oldStarEnemyIntersect = (starEnemyIntersect || oldStarEnemyIntersect);
                    }
                }
            }
        }
        else {
            _currentStar.position = ccp(arc4random_uniform(screenSize.width), arc4random_uniform(screenSize.height));
        }
        
        // add new star to the physics world
        [_physicsNode addChild:_currentStar];
        
        //set star's lifetime to 0
        _currentStar.lifetime = 0;        
        _currentStar.zOrder = 10;
    }
}

-(void) addEnemy {
    
    //makes sure max number of enemies is not exceeded
    if (enemyArray.count < MAX_ENEMIES){
        
        // create an enemy from the ccb-file
        Enemy *_currentEnemy;
        
        //randomly choose enemy type to spawn
        int roundedScore = score/15.0+1;
        int enemyType = arc4random_uniform(clampf(roundedScore, 1, 4));
        switch (enemyType){
            case 0:
                _currentEnemy = (Enemy*)[CCBReader load:@"Enemy2"]; //red enemy
                break;
            case 1:
                _currentEnemy = (Enemy*)[CCBReader load:@"GreenEnemy"]; //green enemy
                break;
            case 2:
                _currentEnemy = (Enemy*)[CCBReader load:@"PinkEnemy"]; //pink enemy
                break;
            case 4:
                _currentEnemy = (Enemy*)[CCBReader load:@"StrawberryEnemy"]; //strawberry enemy
        }
        
        //creates variable of screensize
        CGSize screenSize = [[CCDirector sharedDirector] viewSize];
        
        //prevents enemies from being spawned on player, other enemies, and star
        BOOL avatarEnemyIntersect = TRUE;
        BOOL enemyEnemyIntersect = TRUE;
        BOOL enemyStarIntersect = TRUE;
        BOOL oldEnemyIntersect;
        
        while ((avatarEnemyIntersect) || (oldEnemyIntersect) || (enemyStarIntersect)) {
            
            //make enemy positions
            int randomX = arc4random_uniform(screenSize.width);
            int randomY = arc4random_uniform(screenSize.height);
            
            //sets different clamp depending on type of enemy spawned
            switch (enemyType){
                case 0: //red
                    randomX = clampf(randomX, 23, self.boundingBox.size.width - 23);
                    randomY = clampf(randomY, 48, self.boundingBox.size.height - 48);
                    break;
                case 1: //green
                    randomX = clampf(randomX, 56.5, self.boundingBox.size.width - 56.5);
                    randomY = clampf(randomY, 23, self.boundingBox.size.height - 23);
                    break;
                case 2: //pink
                    randomX = clampf(randomX, 45, self.boundingBox.size.width - 45);
                    randomY = clampf(randomY, 48, self.boundingBox.size.height - 48);
                    break;
                case 3: //strawbery (clamping is wrong)
                    randomX = clampf(randomX, 45, self.boundingBox.size.width - 45);
                    randomY = clampf(randomY, 48, self.boundingBox.size.height - 48);
                    break;
            }

            _currentEnemy.position = ccp(randomX,randomY);
            
            CGRect absoluteEnemyBox = CGRectMake([_currentEnemy boundingBox].origin.x, [_currentEnemy boundingBox].origin.y, [_currentEnemy boundingBox].size.width, [_currentEnemy boundingBox].size.height);
            
            float characterHeight =[_character boundingBox].size.height;
            float characterWidth = [_character boundingBox].size.width;
            CGRect absoluteAvatarBox = CGRectMake([_character boundingBox].origin.x - characterWidth*0.5, [_character boundingBox].origin.y - characterHeight *0.5, characterWidth * 1.5, characterHeight *3.0); // 1.5x to extend BB
            
            oldEnemyIntersect = FALSE;
            
            for (int i=0; i < enemyArray.count; i++) {
                Enemy* _spawnedEnemy = ((Enemy*)enemyArray[i]);
                
                CGRect absoluteSpawnedEnemyBox = CGRectMake([_spawnedEnemy boundingBox].origin.x, [_spawnedEnemy boundingBox].origin.y, [_spawnedEnemy boundingBox].size.width, [_spawnedEnemy boundingBox].size.height);
                
                enemyEnemyIntersect = CGRectIntersectsRect(absoluteEnemyBox, absoluteSpawnedEnemyBox);
                oldEnemyIntersect = (enemyEnemyIntersect || oldEnemyIntersect);
            }
            
            for (int i=0; i < starArray.count; i++) {
                Star* _currentStar = ((Star*)starArray[i]);
                
                CGRect absoluteStarBox = CGRectMake([_currentStar boundingBox].origin.x, [_currentStar boundingBox].origin.y, [_currentStar boundingBox].size.width, [_currentStar boundingBox].size.height);
                
                enemyStarIntersect = CGRectIntersectsRect(absoluteEnemyBox, absoluteStarBox);
            }
            
            avatarEnemyIntersect = CGRectIntersectsRect(absoluteEnemyBox, absoluteAvatarBox);
        }
        
        
        if (_currentEnemy != nil)  {
            //adds new enemy to enemyArray
            [enemyArray addObject:_currentEnemy];
            
            // add new enemy to the physics world
            [_physicsNode addChild: _currentEnemy];
            
            //initiate enemy's lifetime to 0
            _currentEnemy.lifetime = 0;
            
            //run animation sequence for given enemy
            [[_currentEnemy animationManager] runAnimationsForSequenceNamed:@"FadeIn"];
            
            CGFloat currentEnemySpeed = 0;
            switch (enemyType){
                case 0: //red
                    currentEnemySpeed = enemySpeed * 0.65;
                    break;
                case 1: //green
                    currentEnemySpeed = enemySpeed * 0.8;
                    break;
                case 2: //pink
                    currentEnemySpeed = enemySpeed * 1;
                    break;
                case 3: //strawbery (clamping is wrong)
                    currentEnemySpeed = enemySpeed * 1.1;
                    break;
            }
            
            //make enemy follow avatar
            double delayInSeconds = 1.6;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:currentEnemySpeed targetNode:_character followInfinite:NO];
                [_currentEnemy runAction:moveTo];
            });
            
            //play enemy spawn sound
            switch (enemyType){
                case 0: //red
                    [[OALSimpleAudio sharedInstance] playEffect:@"gamesounds/RedSpawn.wav"];
                    break;
                case 1: //green
                    [[OALSimpleAudio sharedInstance] playEffect:@"gamesounds/GreenSpawn.wav"];
                    break;
                case 2: //pink
                    [[OALSimpleAudio sharedInstance] playEffect:@"gamesounds/PinkSpawn.wav"];
                    break;
                case 3: //strawberry
                    [[OALSimpleAudio sharedInstance] playEffect:@"gamesounds/StrawberrySpawn.wav"];
                    break;
            }
            
        }
        _currentEnemy.zOrder = 15;
    }
}

#pragma mark - restart methods

-(void) gameOver {
    _gameOver = TRUE;
    
    //music stops
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio stopBg];
    
    //play sound
    [audio playEffect:@"gamesounds/GameOver.wav"];
    
    //make enemies stop following avatar
    for (int i=0; i < enemyArray.count; i++) {
        Enemy* _spawnedEnemy = ((Enemy*)enemyArray[i]);
        [_spawnedEnemy stopAllActions];
    }
    
    //update total stars collected
    NSInteger oldTotal = [[NSUserDefaults standardUserDefaults] integerForKey:@"Total Stars"];
    NSInteger newTotal = score+oldTotal;
    [[NSUserDefaults standardUserDefaults] setInteger:newTotal forKey:@"Total Stars"];
    
    //update highscore
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"High Score"];
    NSInteger roundScore = score;
    if (roundScore>highScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:roundScore forKey:@"High Score"];
    }
    
    //update score strings
    _roundScoreLabel.string =[NSString stringWithFormat:@"%ld", (long)roundScore];
    if(roundScore >= highScore){
        _highScoreLabel.string = [NSString stringWithFormat:@"%ld", (long)roundScore];
    }
    else {
        _highScoreLabel.string = [NSString stringWithFormat:@"%ld", (long)highScore];
    }
    
    
    paused = TRUE;
    _restartButton.visible = TRUE;
    _gameOverMenu.visible = TRUE;
    _backToMainButton.visible= TRUE;
    [self avatarRemoved:_character];
    
    //submits highscore to server
    [MGWU submitHighScore:score byPlayer:@"Player1" forLeaderboard:@"defaultLeaderboard"];
    
    //submits achievements to server
    [MGWU submitAchievements:achievementArray];
    
    //analytics
    NSNumber* StarsCollected = [NSNumber numberWithInt:score];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: StarsCollected, @"StarsCollectedKey", nil];
    [MGWU logEvent:@"GameOver" withParams:params];
    
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:scene];
    
}

- (void)backtomain {
    if(paused == TRUE) {
    [[CCDirector sharedDirector] resume];
    }
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if(_gameOver ==FALSE){
        paused = !paused;
        if (paused ==TRUE){
            _pausedNode.visible = TRUE;
          //  _backToMainButton.visible= TRUE;
            [[CCDirector sharedDirector] pause];
        }
        else {
            _pausedNode.visible = FALSE;
            _backToMainButton.visible=FALSE;
            [[CCDirector sharedDirector] resume];
        }
    }
}

//#pragma mark - Spinor methods
//
//-(float) Slerp2DfromRadian:(float)from toRadian:(float)to withBlendFactor:(float)blendTime {
//
//    DerekNumber* fromSpinor = [[DerekNumber alloc] initWithRadians:from];
//    DerekNumber* toSpinor = [[DerekNumber alloc] initWithRadians:to];
//    float omega, cosom, sinom, scale0, scale1;
//    float tr,tc;
//
//    //calc cosine
//    cosom = fromSpinor.real * toSpinor.real + fromSpinor.complex *toSpinor.complex;
//
//    //adjust signs
//    if (cosom < 0)
//    {
//        cosom = -cosom;
//        tc = -toSpinor.complex;
//        tr = -toSpinor.real;
//    }
//    else
//    {
//        tc = toSpinor.complex;
//        tr = toSpinor.real;
//    }
//
//    //coefficients
//    if ((1 - cosom) > kSpinorThresHold)
//    {
//        omega = acos(cosom);
//        sinom = sinf(omega);
//        scale0 = sinf((1-blendTime)*omega) / sinom;
//        scale1 = sinf(blendTime*omega) / sinom;
//    }
//    else
//    {
//        scale0 = 1 - blendTime;
//        scale1 = blendTime;
//    }
//
//    DerekNumber* slerped = [[DerekNumber alloc] initWithRadians:0];
//    slerped.real = scale0 * fromSpinor.real + scale1 * tr;
//    slerped.complex = scale0 * fromSpinor.complex + scale1 * tc;
//    slerped.angle = atan2f(slerped.real,slerped.complex)*2;
//    return slerped.angle;
//}
//
////substitute in the multiply function
//-(DerekNumber *) multiplySpinor:(DerekNumber *)spinor1 bySpinor:(DerekNumber *) spinor2{
//
//    float real = spinor1.real * spinor2.real - spinor1.complex * spinor2.complex;
//    float complex = spinor1.real * spinor2.complex + spinor1.complex * spinor2.real;
//    
//    DerekNumber * derek = [[DerekNumber alloc] init];
//    derek.real = real;
//    derek.complex = complex;
//    return derek;
//    
//}

@end
