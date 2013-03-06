//
//  HelloWorldScene.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#import "GameScene.h"
#import "GrowButton.h"
#import "GameSuccessScene.h"
#import "GameOverScene.h"
#import "AppSettings.h"
#import "GameEndScene.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

enum kTag {
    kTagGameSuccessScene = 100,
    kTagGameFailScene,
    kTagGamePauseScene,
};

enum GameState {
    stateReadyAnimating = 0,
    stateReadyShoot,
    stateShooting,
    stateContacted,
    stateEndShooting,
    stateGameEnd,
};

// HelloWorld implementation
@implementation GameScene

-(void)afterStep {
	// process collisions and result from callbacks called by the step
}
////////////////////////////////////////////////////////////////////////////////
-(void)step:(ccTime)dt {
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
	world->ClearForces ();
}
////////////////////////////////////////////////////////////////////////////////
+(id) scene:(int)nworld level:(int)nlevel;
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [[[GameScene alloc] initWithParameters:nworld level:nlevel] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id) initWithParameters:(int)nworld level:(int)nlevel {
    if((self = [super init])){
        m_nworld = nworld;
        m_nlevel = nlevel;
        
        [self initVariables];
        [self initImages];
        [self initWorld];
        [self createListener];
        [self drawLabels];
        [self loadLevel];
        [self createBtns];
        [self createEye];
        [self createSnowParticle];
        
        m_pPopMenu = [[[PopupMenuScene alloc] initWithParameters:m_nworld level:m_nlevel] autorelease];
#ifdef NOT_COMBINE_ADMOBE
        m_pPopMenu.position = ccp(-iDevPixelX(89), iDevPixelY(400));
#else
        m_pPopMenu.position = ccp(-iDevPixelX(89), iDevPixelY(390));
#endif      //NOT_COMBINE_ADMOBE
        
        [self addChild:m_pPopMenu z:_TOP_Z];
        
        [m_soundManager playBackgroundMusic:soundGameBGM];
        
        [self schedule:@selector(onTime:) interval:1.0f / 40.0f];
        [self schedule:@selector(onDisplayTime:) interval:0.3f];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////
-(void) initVariables {
    m_appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    m_soundManager = [SoundManager sharedSoundManager];
    
    self.isTouchEnabled = YES;
    m_level = nil;
    m_pContactListener = nil;
    m_bTouch = false;
    m_FixPosition = ccp(iDevPixelX(187), iDevPixelY(377));
    m_EyePosition = ccp(iDevPixelX(187), iDevPixelY(347));
    m_GameState = stateReadyAnimating;
    m_pScoreLabel = nil;
    m_nScoreLblIndex = 0;
    m_nEyeCount = MAX_LIVES_COUNT;
    m_aniEyeTime = 0;
    m_fRemainTime = MAX_LEVEL_TIME;
    m_bPaused = false;
    m_pPauseLabel = nil;
    m_bPopUpMenuAnimating = false;
    
    if (g_bTestMode == true) {
        m_nEyeCount = 100;
        m_fRemainTime = 600;
    }
    
    if (m_nworld == 0 && m_nlevel == 0) {
        m_nScore = 0;
    }
    else {
        m_nScore = [AppSettings getScore:m_nworld nlevel:m_nlevel - 1];
    }
    [self setScore];
    
    g_ContactObj = [[NSMutableArray alloc] init];
    g_ContactEnemy = [[NSMutableArray alloc] init];
    
    m_EyesPosition = ccp(iDevPixelX(276), iDevPixelY(405));
    
    m_nShootCount = 0;
    [self setLives];
    
    // enable accelerometer
    self.isAccelerometerEnabled = YES;
    
    [[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
}

//////////////////////////////////////////////////////////////////////////////
-(void) initImages {
    CGRect rtSky = CGRectMake(0, iDevPixelY(220), SCREEN_WIDTH, iDevPixelY(120));
    for (int i = 0; i < 3; i++) {
        m_sprCloud[i] = [SpriteCloud spriteWithFile:[NSString stringWithFormat:@"cloud%d.png", i + 1]];
        [m_sprCloud[i] setSkyRect:rtSky];
        [self addChild:m_sprCloud[i]];
        if (m_nworld == 1) {
            [m_sprCloud[i] setOpacity:180];
        }
    }
    
    m_sprEye = [[CCSprite spriteWithFile:@"eye_fire.png"] retain];
    m_sprEye.scale = 0.5;
}

//////////////////////////////////////////////////////////////////////////////
-(void) initWorld {
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, -0.3f);
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    world = new b2World(gravity);
    
    world->SetContinuousPhysics(true);    
    
#ifdef DEBUG
    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw();
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    m_debugDraw->SetFlags(flags);
#endif
    [self schedule: @selector(tick:)];
}

//////////////////////////////////////////////////////////////////////////////
-(void) drawLabels {
#ifdef NOT_COMBINE_ADMOBE
    m_pTimeLabel = [CCLabelFX labelWithString:nil dimensions:CGSizeMake(iDevPixelX(120), iDevPixelY(24)) alignment:CCTextAlignmentLeft fontName:@"Imagica" fontSize:iDevSize(20) shadowOffset:CGSizeMake(iDevPixelX(0), -iDevPixelY(0)) shadowBlur:0.5f shadowColor:ccc4(0, 0, 255, 0) fillColor:ccc4(0, 0, 255, 255)];
    m_pTimeLabel.position = ccp(iDevPixelX(270), iDevPixelY(450));
#else
    m_pTimeLabel = [CCLabelFX labelWithString:nil dimensions:CGSizeMake(iDevPixelX(100), iDevPixelY(18)) alignment:CCTextAlignmentLeft fontName:@"Imagica" fontSize:iDevSize(16) shadowOffset:CGSizeMake(iDevPixelX(0), -iDevPixelY(0)) shadowBlur:0.5f shadowColor:ccc4(0, 0, 255, 0) fillColor:ccc4(0, 0, 255, 255)];
    m_pTimeLabel.position = ccp(iDevPixelX(280), iDevPixelY(440));
#endif      //NOT_COMBINE_ADMOBE
    
    [self addChild:m_pTimeLabel];
    
    CCLabelFX* pWorldLbl = [CCLabelFX labelWithString:[NSString stringWithFormat:@"World %d-%d", m_nworld + 1, m_nlevel + 1] fontName:@"Imagica" fontSize:iDevSize(30) shadowOffset:CGSizeMake(iDevPixelX(2), -iDevPixelY(2)) shadowBlur:0.5f];
    pWorldLbl.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.45);
    [pWorldLbl setScale:0.0f];
    [self addChild:pWorldLbl z:_TOP_Z - 1];
    [self worldLabelAnimation:pWorldLbl];
}

//////////////////////////////////////////////////////////////////////////////
-(void) worldLabelAnimation:(CCLabelFX*) pLabel {
    [pLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f],
                       [CCScaleTo actionWithDuration:0.5f scale:1.4f],
                       [CCScaleTo actionWithDuration:0.2f scale:0.85f],
                       [CCScaleTo actionWithDuration:0.1f scale:1.0f],
                       [CCDelayTime actionWithDuration:1.0f],
                       [CCFadeOut actionWithDuration:0.5f],
                       nil]];
}

//////////////////////////////////////////////////////////////////////////////
-(void) createBtns
{
    CCSprite *spritePlay = [CCSprite spriteWithFile:@"btn-pause_gameScreen.png"];
    CCSprite *spritePlaySel = [CCSprite spriteWithFile:@"btnPressed-pause_gameScreen.png"];
    
    menuPauseItem = [CCMenuItemSprite itemFromNormalSprite:spritePlay selectedSprite:spritePlaySel target:self selector:@selector(onPause)];
    menuPause  = [CCMenu menuWithItems:menuPauseItem, nil];
    menuPause.position = ccp(20, 20);
    [self addChild:menuPause];

//    m_pMenuBtn = [GrowButton buttonWithSprite: @"popup_menu.png"
//                           selectImage: @"popup_menu.png"
//                                target: self
//                              selector: @selector(actionBack:)];
//#ifdef NOT_COMBINE_ADMOBE
//    m_pMenuBtn.position =  ccp(iDevPixelX(25), iDevPixelY(400));
//#else
//	m_pMenuBtn.position =  ccp(iDevPixelX(25), iDevPixelY(390));
//#endif      //NOT_COMBINE_ADMOBE
//	[self addChild:m_pMenuBtn];
}

//////////////////////////////////////////////////////////////////////////////
-(void) createEye {
    if (m_pEye) {
        [m_pEye release];
        m_pEye = nil;
    }
    if (g_bTestMode) {
        g_SelectedEye = FIRE_EYE_TAG;
        m_pEye = [[Eye alloc] initWithWorld:world pos:m_EyePosition Parent:self];
        g_EyeContacted = false;
        return;
    }
    if (m_nShootCount < MAX_LIVES_COUNT) {
        g_SelectedEye = FIRE_EYE_TAG;
        m_pEye = [[Eye alloc] initWithWorld:world pos:m_EyePosition Parent:self];
        g_EyeContacted = false;
    }
    
    m_nEyeCount--;
}

-(void) createSnowParticle {
    if (m_nworld != 1) {
        return;
    }
    CCParticleSnow *snowEmitter;
	snowEmitter = [CCParticleSnow node];
	snowEmitter.position = ccp(iDevPixelX(160), iDevPixelY(480));
	snowEmitter.life = iDevSize(13);
	snowEmitter.lifeVar = iDevSize(2);
	
	// gravity
	snowEmitter.gravity = ccp(iDevPixelY(-1),iDevPixelY(-5));
	
	// speed of particles
	snowEmitter.speed = 100;
	snowEmitter.speedVar = iDevSize(30);
	
	
	ccColor4F startColor = snowEmitter.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	snowEmitter.startColor = startColor;
	
	ccColor4F startColorVar = snowEmitter.startColorVar;
	startColorVar.b = 0.1f;
	snowEmitter.startColorVar = startColorVar;
	snowEmitter.emissionRate = (float)snowEmitter.totalParticles/(float)snowEmitter.life;
	snowEmitter.startSize = iDevSize(snowEmitter.startSize);
	snowEmitter.endSize = iDevSize(snowEmitter.endSize);
    snowEmitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
    
    [self addChild:snowEmitter z:_TOP_Z];
}
//////////////////////////////////////////////////////////////////////////////
-(void) loadLevel {
    if(m_level != nil){
        [m_level release];
        m_level = nil;
    }
	m_level = [[LevelHelperLoader alloc] initWithContentOfFile:[NSString stringWithFormat:@"level%d", m_nworld * LEVEL_COUNT + m_nlevel]];
    
	//notification have to be added before creating the objects
    //if you dont want notifications - it is better to remove this lines
    [m_level registerNotifierOnAllPathEndPoints:self selector:@selector(spriteMoveOnPathEnded:pathUniqueName:)];
    [m_level registerNotifierOnAllAnimationEnds:self selector:@selector(spriteAnimHasEnded:animationName:)];
    [m_level enableNotifOnLoopForeverAnimations];
    
    
    //creating the objects
    [m_level addObjectsToWorld:world cocos2dLayer:self];
    
    if([m_level hasPhysicBoundaries])
        [m_level createPhysicBoundaries:world];
    
    if(![m_level isGravityZero])
        [m_level createGravity:world];
    
    NSArray * array = [m_level spritesWithTag:ENEMY1_TAG];
    m_nEnemyCount = [array count];
}

////////////////////////////////////////////////////////////////////////////////
- (void) setScore {
    if (m_pScoreLabel == nil) {
#ifdef NOT_COMBINE_ADMOBE
        m_pScoreLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"SCORE : %d", m_nScore] dimensions:CGSizeMake(iDevPixelX(160), iDevPixelY(24)) alignment:CCTextAlignmentLeft fontName:@"Imagica" fontSize:iDevSize(20) shadowOffset:CGSizeMake(iDevPixelX(0), -iDevPixelY(0)) shadowBlur:0.5f shadowColor:ccc4(255, 0, 0, 0) fillColor:ccc4(255, 0, 0, 255)];
        m_pScoreLabel.position = ccp(iDevPixelX(90), iDevPixelY(450));
#else
        m_pScoreLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"SCORE : %d", m_nScore] dimensions:CGSizeMake(iDevPixelX(150), iDevPixelY(18)) alignment:CCTextAlignmentLeft fontName:@"Imagica" fontSize:iDevSize(16) shadowOffset:CGSizeMake(iDevPixelX(0), -iDevPixelY(0)) shadowBlur:0.5f shadowColor:ccc4(255, 0, 0, 0) fillColor:ccc4(255, 0, 0, 255)];
        m_pScoreLabel.position = ccp(iDevPixelX(85), iDevPixelY(440));
#endif      //NOT_COMBINE_ADMOBE
        [self addChild:m_pScoreLabel];
    }
    else {
        [m_pScoreLabel setString:[NSString stringWithFormat:@"SCORE : %d", m_nScore]];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void) setLives {
//    if (m_pLivesLabel == nil) {
//        m_pLivesLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"%d", MAX_LIVES_COUNT - m_nShootCount] fontName:@"Imagica" fontSize:iDevSize(16) shadowOffset:CGSizeMake(iDevPixelX(2), -iDevPixelY(2)) shadowBlur:0.5f];
//        m_pLivesLabel.position = ccp(iDevPixelX(250), iDevPixelY(465));
//        [self addChild:m_pLivesLabel];
//    }
//    else {
//        [m_pLivesLabel setString:[NSString stringWithFormat:@"%d", MAX_LIVES_COUNT - m_nShootCount]];
//    }
}

-(void) EyeReadyAniEnd {
    if (m_GameState == stateGameEnd) {
        return;
    }
    m_GameState = stateReadyShoot;
}

////////////////////////////////////////////////////////////////////////////////
-(void)spriteMoveOnPathEnded:(LHSprite*)spr pathUniqueName:(NSString*)pathName
{
    NSLog(@"Sprite \"%@\" movement on path \"%@\" has just ended.", [spr uniqueName], pathName);    
}

////////////////////////////////////////////////////////////////////////////////
-(void) spriteAnimHasEnded:(LHSprite*)spr animationName:(NSString*)animName
{
    NSLog(@"Animation with name %@ has ended on sprite %@", animName, [spr uniqueName]);
    if ([animName isEqualToString:@"fireAnimation"] || 
        [animName isEqualToString:@"acidAnimation"] || 
        [animName isEqualToString:@"metalAnimation"] || 
        [animName isEqualToString:@"iceAnimation"]) {
        
        [m_pEye release];
        m_pEye = nil;
        [self createEye];
        m_GameState = stateEndShooting;
    }
    else if ([animName isEqualToString:@"exploid1"]) {
        [m_level removeSprite:spr];
    }
    else if ([animName isEqualToString:@"exploid_wood"]) {
        [m_level removeSprite:spr];
    }
}

////////////////////////////////////////////////////////////////////////////////
-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
    if (m_pEye) {
        [m_pEye draw];
    }
    
    for (int i = 0; i < m_nEyeCount; i++) {
        [m_sprEye setPosition:ccpAdd(m_EyesPosition, ccp(iDevPixelX(7) * i, iDevPixelY(0.5) * i))];
        [m_sprEye visit];
    }
}

////////////////////////////////////////////////////////////////////////////////
//FIX TIME STEPT------------>>>>>>>>>>>>>>>>>>
-(void) tick: (ccTime) dt
{
    for (int i = 0; i < 3; i++) {
        [m_sprCloud[i] update:dt];
    }
    
	[self step:dt];
    
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
        {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            
            if(myActor != 0)
            {
                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());		
            }
        }
	}	
}

//FIX TIME STEPT<<<<<<<<<<<<<<<----------------------
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (![m_pMenuBtn visible] && !m_bPaused && !m_bPopUpMenuAnimating) {
        [self PopupMenuAnimation:false];
        return;
    }
    CGPoint location;
    for( UITouch *touch in touches ) {
		
        location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];        
        
        if(nil != m_level)
        {
            b2Body* body = [m_level bodyWithTag:DEFAULT_TAG touchedAtPoint:CGPointMake(location.x, location.y)];
            if(0 != body)
            {
                //make sure you have physic boundaries in the level or this method will fail
                mouseJoint = [m_level mouseJointForBodyA:[m_level bottomPhysicBoundary]
                                                   bodyB:body 
                                              touchPoint:location];
            }
        }
        m_ptClickPos = location;
    }
    if (m_bPaused == false && m_GameState == stateReadyShoot/* && ccpDistance(m_EyePosition, location) < iDevSize(20)*/) {
        m_bTouch = true;
        [self MoveEye:m_FixPosition ptEnd:m_EyePosition];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for( UITouch *touch in touches ) {
		
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];        
        m_DragPosition = location;
        
        if(nil != mouseJoint)
        {
            if(nil != m_level)
            {
                [m_level setTarget:location onMouseJoint:mouseJoint];
            }
        }
        if (m_bTouch) {
            [self MoveEye:m_FixPosition ptEnd:ccpAdd(m_FixPosition, ccpSub(m_DragPosition, m_ptClickPos))];
        }        
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(mouseJoint != 0){    
		world->DestroyJoint(mouseJoint);
		mouseJoint = NULL;
	}
    
	for( UITouch *touch in touches ) {
        
		CGPoint location = [touch locationInView: [touch view]];
		m_DragPosition = [[CCDirector sharedDirector] convertToGL: location];
		if (m_bTouch) {
            CGPoint ptVel = ccpSub(m_ptClickPos, m_DragPosition);
            if (abs(ptVel.x) > MAXVEL) {
                ptVel.x = (ptVel.x/abs(ptVel.x))*MAXVEL;
            }
            if (abs(ptVel.y) > MAXVEL) {
                ptVel.y = (ptVel.y/abs(ptVel.y))*MAXVEL;
            }
            
            [m_pEye createObject:[m_pEye getSprPosition]];
            m_nShootCount++;
            if (m_pEye.body) {
                m_pEye.body->SetType(b2_dynamicBody);
                [m_pEye applyForce:ptVel.x * 6 y:ptVel.y * 6];
                m_GameState = stateShooting;
                
//                switch ([m_pEye getEyeTag]) {
//                    case FIRE_EYE_TAG:
//                    {
//                        [m_level startAnimationWithUniqueName:@"fireDropAnimation" onSprite:[m_pEye getUserData]];
//                    }
//                        break;
//                    case ACID_EYE_TAG:
//                    {
//                        [m_level startAnimationWithUniqueName:@"acidDropAnimation" onSprite:[m_pEye getUserData]];
//                    }
//                        break;    
//                    default:
//                        break;
//                }
            }
        }        
	}
    
    [self setLives];
    
    m_bTouch = false;
}

////////////////////////////////////////////////////////////////////////////////
-(void) MoveEye:(CGPoint)ptFixed ptEnd:(CGPoint)ptEnd {
    float distance = ccpDistance(ptEnd, ptFixed);
    
    float fAngle = ccpToAngle(ccpSub(ptEnd, ptFixed));
    
    if (distance > iDevSize(60)) {
        distance = iDevSize(60);
        ptEnd.x = ptFixed.x + distance * cosf(fAngle);
        ptEnd.y = ptFixed.y + distance * sinf(fAngle);
    }
    [m_pEye setPosition:ptEnd];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Pause Screen
-(void) onPlay
{
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [self onPause:false];
}

-(void)onPause
{
    [self onPause:true];
}
-(void) onPause:(bool)bPaused
{
    m_bPaused = bPaused;
    if (m_bPaused)
    {
        if (m_pSprPause) {
            [m_pSprPause setVisible:YES];
        }
        else {
            
            m_pSprPause = [CCSprite spriteWithFile:@"trans_back.png"];
            m_pSprPause.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
            [self addChild:m_pSprPause z:_TOP_Z - 1 tag:kTagGamePauseScene];
        }
        
        
        if (menuResume)
        {
            [menuResume setVisible:YES];
        }
        else
        {
            CCSprite *spritePlay = [CCSprite spriteWithFile:@"btn-play_gameScreen.png"];
            CCSprite *spritePlaySel = [CCSprite spriteWithFile:@"btnPressed-play_gameScreen.png"];
            
            menuResumeItem = [CCMenuItemSprite itemFromNormalSprite:spritePlay selectedSprite:spritePlaySel target:self selector:@selector(onPlay)];
            menuResume  = [CCMenu menuWithItems:menuResumeItem, nil];
            menuResume.position = ccp(20, 20);
            [self addChild:menuResume];
        }
    }
    else
    {
        if (m_pSprPause) {
            [m_pSprPause setVisible:NO];
        }
        
        if (menuResume) {
            [menuResume setVisible:NO];
        }
        
        if (menuPause) {
            [menuPause setVisible:YES];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void) createListener
{
	m_pContactListener = new MyListener();
	world->SetContactListener(m_pContactListener);
}

////////////////////////////////////////////////////////////////////////////////
-(void) onTime:(ccTime) dt {
    
    if (m_GameState == stateReadyShoot && [AppSettings getPlayMode] == MODE_TIME && m_fRemainTime <= 0) {
        [self FailProcess];
        return;
    }
    
    if (g_EyeContacted) {
        LHSprite* sprEye = [m_pEye getUserData];
        if (sprEye && m_GameState == stateShooting) {
            switch ([sprEye tag]) {
                case FIRE_EYE_TAG:
                    [m_level startAnimationWithUniqueName:@"fireAnimation" onSprite:sprEye];
                    break;
                case ACID_EYE_TAG:
                    [m_level startAnimationWithUniqueName:@"acidAnimation" onSprite:sprEye];
                    break;
                case METAL_EYE_TAG:
                    [m_level startAnimationWithUniqueName:@"metalAnimation" onSprite:sprEye];
                    break;
                case ICE_EYE_TAG:
                    [m_level startAnimationWithUniqueName:@"iceAnimation" onSprite:sprEye];
                    break;
                default:
                    break;
            }
            
            [m_soundManager playEffect:soundExploid loop:NO];
            
            [sprEye body]->SetType(b2_staticBody);
            m_GameState = stateContacted;
        }
    }
        
        for (LHSprite* contactObj in g_ContactObj) {
            if ([contactObj numberOfRunningActions] == 0) {
                [contactObj body]->SetType(b2_staticBody);
                NSArray * jointarray = [m_level jointsWithTag:DEFAULT_TAG];
                for (LHJoint* joint in jointarray) {
                    if ([contactObj body] == [joint joint]->GetBodyA() || [contactObj body] == [joint joint]->GetBodyB()) {
                        [m_level removeJoint:joint];
                    }
                }
                if ([contactObj tag] == WOOD_TAG) {
                    [m_level startAnimationWithUniqueName:@"exploid_wood" onSprite:contactObj];
                }
                else {
                    [m_level startAnimationWithUniqueName:@"exploid1" onSprite:contactObj];
                }
                m_nScore += 50;
                
                [m_soundManager playEffect:soundExploid loop:NO];
                
                [self scoreLabelAnimation:50 ptPos:[contactObj position]];
                [self setScore];
            }
        }
        
        for (LHSprite* contactObj in g_ContactEnemy) {
            if ([contactObj numberOfRunningActions] == 0) {
                [contactObj body]->SetType(b2_staticBody);
                [m_level startAnimationWithUniqueName:@"exploid1" onSprite:contactObj];
                m_nEnemyCount--;
                [self scoreLabelAnimation:500 ptPos:[contactObj position]];
                m_nScore += 500;
                
                [m_soundManager playEffect:soundExploid loop:NO];
                
                [self setScore];
            }
        }
    //}
    
    [g_ContactEnemy removeAllObjects];
    [g_ContactObj removeAllObjects];
    
    if (m_GameState == stateEndShooting || m_GameState == stateReadyShoot || m_GameState == stateReadyAnimating) 
    {
        if ([self checkGameSussess]) {
            return;
        }
        if ([self checkGameFail]) {
            return;
        }
    }
    
    if (m_GameState == stateEndShooting) {
        m_GameState = stateReadyAnimating;
    }
    
    if (m_GameState < stateShooting && !m_bTouch) {
        if (m_aniEyeTime < EYE_ANI_TIME) {
            m_aniEyeTime += dt;
        }
        else {
            m_aniEyeTime = 0;
            int nEyeTag = [m_pEye getEyeTag];
            if (nEyeTag == ACID_EYE_TAG + m_nworld) {
                nEyeTag = FIRE_EYE_TAG;
            }
            else
                nEyeTag += 1;
            g_SelectedEye = nEyeTag;
            [m_pEye setEyeTag:nEyeTag];
        }
    }
}

-(void) onDisplayTime:(ccTime) dt {
//    NSDate *myDate = [NSDate date];
//    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//    [formatter setDateFormat:@"SS"];
//    NSString *str_lastMiri = [formatter stringFromDate: myDate];
//   
    if (m_bPaused) {
        return;
    }
    m_fGameTime += dt;
    
	long lOffset;
    switch ([AppSettings getPlayMode]) {
        case MODE_TIME:
            m_fRemainTime = lOffset = MAX_LEVEL_TIME - m_fGameTime;            
            break;
        case MODE_DESTRUCTION:
            lOffset = m_fGameTime;
            break;    
        default:
            break;
    }
	int n_lastSec = lOffset % 60;
	int n_lastMin = (lOffset / 60) % 60;
	//int n_lastHour = lOffset / 60 / 60;
    
    if (lOffset < 0) {
        n_lastMin = n_lastSec = 0;
    }
	//NSString *str = [NSString stringWithFormat:@"Time : %02d:%02d.%@", n_lastMin, n_lastSec, str_lastMiri];
    NSString *str = [NSString stringWithFormat:@"TIME : %02d:%02d", n_lastMin, n_lastSec];
    [m_pTimeLabel setString:str];
}

////////////////////////////////////////////////////////////////////////////////
- (bool) checkGameSussess {
#ifdef DEBUG
    if (m_nEnemyCount <= 0) {
        [self SuccessProcess];
        return true;
    }
    return false;
#else
    if (m_nEnemyCount <= 0) {
        [self SuccessProcess];
        return true;
    }
    return false;
#endif
}

////////////////////////////////////////////////////////////////////////////////
- (bool) checkGameFail {
    if (g_bTestMode) {
        return false;
    }
    if (m_nShootCount >= MAX_LIVES_COUNT) {
        [self FailProcess];
        return true;
    }
    return false;
}

- (void) SuccessProcess {
    [AppSettings setScore:m_nworld nlevel:m_nlevel nScore:m_nScore];
    if (g_bTestMode) {
        m_nEyeCount = 1;
    }
    if (m_nworld == 2 && m_nlevel == LEVEL_COUNT - 1) {
        GameEndScene * layer = [[[GameEndScene alloc] initWithParameters:m_nworld level:m_nlevel remainEyes:m_nEyeCount] autorelease];
        [self addChild:layer z:_TOP_Z tag:kTagGameSuccessScene];
        [self ResultLayerAnimation:layer];
    }
    else {
        GameSuccessScene * layer = [[[GameSuccessScene alloc] initWithParameters:m_nworld level:m_nlevel remainEyes:m_nEyeCount] autorelease];
        [self addChild:layer z:_TOP_Z tag:kTagGameSuccessScene];
        [self ResultLayerAnimation:layer];
    }
    
    [self unschedule:@selector(onTime:)];
    [self unschedule:@selector(onDisplayTime:)];
    
    m_GameState = stateGameEnd;
}

- (void) FailProcess {
    [AppSettings setScore:m_nworld nlevel:m_nlevel nScore:m_nScore];
    
    GameOverScene* layer = [[[GameOverScene alloc] initWithParameters:m_nworld level:m_nlevel] autorelease];
    [self addChild:layer z:_TOP_Z tag:kTagGameFailScene];
    [self ResultLayerAnimation:layer];
    
    [self unschedule:@selector(onTime:)];
    [self unschedule:@selector(onDisplayTime:)];
    
    m_GameState = stateGameEnd;
}

////////////////////////////////////////////////////////////////////////////////
- (void) actionBack: (id) sender
{
    if (m_GameState == stateGameEnd) {
        return;
    }
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [self PopupMenuAnimation:true];
    [m_pMenuBtn setVisible: NO];
}

////////////////////////////////////////////////////////////////////////////////
- (void) actionFire: (id) sender
{
    if (m_GameState > stateShooting) {
        return;
    }
    g_SelectedEye = FIRE_EYE_TAG;
    [m_pEye setEyeTag:FIRE_EYE_TAG];
}

////////////////////////////////////////////////////////////////////////////////
- (void) actionAcid: (id) sender
{
    if (m_GameState > stateShooting) {
        return;
    }
    g_SelectedEye = ACID_EYE_TAG;
    [m_pEye setEyeTag:ACID_EYE_TAG];
}

////////////////////////////////////////////////////////////////////////////////
-(void) scoreLabelAnimation:(int)nScore ptPos:(CGPoint)ptPos {
    CCLabelFX * pLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d", nScore] fontName:@"Imagica" fontSize:iDevSize(16) shadowOffset:CGSizeMake(iDevPixelX(2), -iDevPixelY(2)) shadowBlur:0.5f];
    pLabel.position = ptPos;
    [pLabel setScale:0.0f];
    [self addChild:pLabel z:_TOP_Z tag:SCORE_LABEL_INDEX + m_nScoreLblIndex];
    
    if (nScore > 50) {
        [pLabel setColor:ccc3(255, 0, 0)];
    }    
    
    [pLabel runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:1.2f], 
                                        [CCScaleTo actionWithDuration:0.2 scale:1.0f], 
                                        [CCDelayTime actionWithDuration:1.0f],
                                        [CCFadeOut actionWithDuration:0.5f],
                                        nil]];
    
    m_nScoreLblIndex++;
}

////////////////////////////////////////////////////////////////////////////////
-(void) ResultLayerAnimation:(CCLayer*) layer {
    [layer runAction:[CCSequence actions:
                      [CCMoveBy actionWithDuration:0.3f position:ccp(0, - SCREEN_HEIGHT * 0.7)],
                      [CCMoveBy actionWithDuration:0.2f position:ccp(0, SCREEN_HEIGHT * 0.15)],
                      [CCMoveBy actionWithDuration:0.15f position:ccp(0, - SCREEN_HEIGHT * 0.07)],
                      [CCMoveBy actionWithDuration:0.1f position:ccp(0, SCREEN_HEIGHT * 0.02)],
                      nil]];
}

////////////////////////////////////////////////////////////////////////////////
-(void) PopupMenuAnimation:(bool)appear {
    CGPoint pos;
    if (appear) {
#ifdef NOT_COMBINE_ADMOBE
        pos = ccp(iDevPixelX(79), iDevPixelY(400));
#else
        pos = ccp(iDevPixelX(79), iDevPixelY(390));
#endif      //NOT_COMBINE_ADMOBE
        [m_pPopMenu runAction:[CCMoveTo actionWithDuration:0.6 position:pos]];
    }
    else {
        m_bPopUpMenuAnimating = true;
#ifdef NOT_COMBINE_ADMOBE
        pos = ccp(-iDevPixelX(89), iDevPixelY(400));
#else
        pos = ccp(-iDevPixelX(89), iDevPixelY(390));
#endif      //NOT_COMBINE_ADMOBE
        [m_pPopMenu runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.6 position:pos],
                             [CCCallFuncN actionWithTarget:self selector:@selector(PopupMenuDisappeared)],
                             nil]];
    }
}

////////////////////////////////////////////////////////////////////////////////
-(void) PopupMenuDisappeared {
    [m_pMenuBtn setVisible:YES];
    m_bPopUpMenuAnimating = false;
}

////////////////////////////////////////////////////////////////////////////////
- (void)accelerometer:(UIAccelerometer*)accelerometer 
        didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
    //	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
    //	world->SetGravity( gravity );
}

////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCNode * node = [self getChildByTag:kTagGamePauseScene];
    if (node) {
        [self removeChild:node cleanup:YES];
    }
    
    [m_soundManager stopBackgroundMusic];
    
    [m_sprEye release];
    
    for (int i = 0; i < m_nScoreLblIndex; i++) {
        CCNode* node = [self getChildByTag:SCORE_LABEL_INDEX + i];
        if (node) {
            [node stopAllActions];
            [node removeFromParentAndCleanup:YES];
        }
    }
    m_nScoreLblIndex = 0;
    
    [self unschedule:@selector(onTime:)];
    
    [g_ContactObj release];
    [g_ContactEnemy release];
    
    if (m_pEye) {
        [m_pEye release];
    }   
    
    if(mouseJoint != 0){    
		world->DestroyJoint(mouseJoint);
		mouseJoint = NULL;
	}
    
    if(nil != m_level)
        [m_level release];
    
    if(m_pContactListener != nil)
        delete m_pContactListener;
    m_pContactListener = nil;
        
	delete world;
	world = NULL;
	
  	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
////////////////////////////////////////////////////////////////////////////////