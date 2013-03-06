//
//  StageScene.m
//  Game
//
//  Created by hrh on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StageScene.h"
#import "ResourceManager.h"
#import "GrowButton.h"
#import "GrowScaleButton.h"
#import "AppSettings.h"
#import "AppDelegate.h"
#import "CCLabelFX.h"
#import "ModeScene.h"
#import "TitleScene.h"

//#import "Terrain.h"
//#import "Sky.h"

#define kTagArrowLeft	2
#define kTagArrowRight	3
#define kTag_Lock		4
#define kTag_Unlock		5
#define kTag_Buy		6

#define INTERVAL_X          73
#define INTERVAL_Y          75
#define FIRSTPOS_X          50
#define FIRSTPOS_Y          200

// option_back
// s_preview%d
// lock
// playbutton
// back
// s_arrow_left
// s_arrow_right


@interface StageScene()
- (void) loadResource;
- (void) unloadResource;
- (void) createLevelButton;
- (void) createButtons;
@end


@implementation StageScene
@synthesize sprViewLevel=_sprViewLevel;
@synthesize unlockMenu=_unlockMenu;

+ (CCScene*) scene {
    CCScene *scene = [CCScene node];
    [scene addChild:[StageScene node]];
    return scene;
}

- (id) init {
    
	if ((self = [super init])) 
	{
        self.isTouchEnabled = YES;
		
		m_app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_soundManager = [SoundManager sharedSoundManager];
        if (![m_soundManager isBackgroundMusicPlaying]) {
            [m_soundManager playBackgroundMusic:soundMenuBGM];
        }
        
        m_bChangeWorldAnimating = false;
        
        _world = [AppSettings getCurWorld];
        if (_world >= 3) {
            _world = 0;
        }
        _level = [AppSettings getCurLevel:_world];
        
		[self loadResource];
		[self createLevelButton];
		[self createButtons];
//		[self setPropertyOfSprites];
	}
	
	return self;
}

- (void) dealloc
{    
	[self unloadResource];
	
    _sprViewLevel = nil;
	
	[super dealloc];
}

- (void) loadResource
{
	m_spriteBack = [CCSprite spriteWithFile: [NSString stringWithFormat:@"level_bg_%d.png", _world]];
    m_spriteBack.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self addChild:m_spriteBack z:-2];
        
    m_sprLock = [[CCSprite spriteWithFile:@"lock.png"] retain];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && CC_CONTENT_SCALE_FACTOR() == 1) {
        [m_sprLock setScale:0.5f];
    }
	
	m_lblLevel = [[CCLabelFX labelWithString:nil fontName:@"Imagica" fontSize:iDevSize(24) shadowOffset:CGSizeMake(iDevPixelX(2), -iDevPixelY(2)) shadowBlur:0.5f] retain];
    [m_lblLevel setShadowColor:ccc4(0, 0, 0, 255)];
}

- (void) unloadResource
{
    [m_sprLock release];
    [m_lblLevel release];
}

- (void) createLevelButton
{
	NSString* str;
    switch ([AppSettings getPlayMode]) {
        case MODE_TIME:
            str = [NSString stringWithFormat: @"mt_world%d_preview.png", _world];
            break;
        case MODE_DESTRUCTION:
            str = [NSString stringWithFormat: @"world%d_preview.png", _world];
            break;   
        default:
            break;
    }
	_sprViewLevel = [CCSprite spriteWithFile:str];
	[_sprViewLevel setPosition: ccp(iDevPixelX(160), iDevPixelY(330))];
	[self addChild: _sprViewLevel];
    
    CGPoint pos;
    for (int i = 0; i < 3; i ++) {
        for (int j = 0; j < 4; j++) {            
            m_sprLevel[i * 4 + j] = [[CCSprite spriteWithFile:@"level_preview.png"] retain];
            pos = ccp(iDevPixelX(FIRSTPOS_X) + j * iDevPixelX(INTERVAL_X), iDevPixelY(FIRSTPOS_Y) - iDevPixelY(INTERVAL_Y) * i);
            [m_sprLevel[i * 4 + j] setPosition:pos];
            [self addChild:m_sprLevel[i * 4 + j] z:-1];
            [m_sprLevel[i * 4 + j] setScale:1.0f];
        }
    }
}

- (void) createButtons
{

	GrowButton *btnBack;
	btnBack = [GrowButton buttonWithSprite: @"level_back_0.png"
							selectImage: @"level_back_0.png"
									 target: self
								   selector: @selector(actionBack:)];
	btnBack.position =  ccp(iDevPixelX(30), iDevPixelY(450));
	[self addChild:btnBack];
	
	GrowScaleButton* btn = [GrowScaleButton buttonWithSprite: @"arrow_left.png"
							selectImage: @"arrow_left.png"
									 target: self
								   selector: @selector(actionArrowLeft:)];
	btn.position =  ccp(iDevPixelX(30), iDevPixelY(340));
	[self addChild:btn];
	
	btn = [GrowScaleButton buttonWithSprite: @"arrow_right.png"
							selectImage: @"arrow_right.png"
									 target: self
								   selector: @selector(actionArrowRight:)];
	btn.position =  ccp(iDevPixelX(290), iDevPixelY(340));
	[self addChild:btn];
    
    
}

- (void) actionPlay:(id)sender
{
    
}

- (void) gotoGame:(int)world level:(int)level {
    if(level >= [AppSettings getCurLevel:_world]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                        message: [NSString stringWithFormat: @"You can't play the level%d.", level + 1]
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        //		[alert setTag: kTag_Unlock];
        [alert show];	
        [alert release];
        return;
    }
    [self levelBtnClickAnimation:m_sprLevel[level]];
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_app changeWindow:WND_GAME param1:world param2:level];
}

- (void) actionBack: (id) sender
{
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
#ifdef USE_LOADING_SCENE
    [m_app changeWindow:WND_MODE];
#else
//    CCScene * scene = [ModeScene node];
    CCScene * scene = [TitleScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

- (void) animateStagePreview
{
    float y = iDevPixelX(330);
    id aniStartFunc = [CCCallFunc actionWithTarget:self selector:@selector(changeWorldAnimationStart)];
    id aniEndFunc = [CCCallFunc actionWithTarget:self selector:@selector(changeWorldAnimationEnd)];
	id movetozero = [CCMoveTo actionWithDuration:0.1f position:ccp(0, y)];
	id ease       = [CCEaseBackInOut actionWithAction:movetozero];
	id moveto     = [CCMoveTo actionWithDuration:0.1f position:ccp(iDevPixelX(320), y)];
	id backto     = [CCMoveTo actionWithDuration:0.1f position:ccp(iDevPixelX(150), y)];
	id backto1    = [CCMoveTo actionWithDuration:0.1f position:ccp(iDevPixelX(170), y)];
	id backto2    = [CCMoveTo actionWithDuration:0.1f position:ccp(iDevPixelX(155), y)];
	id backto3    = [CCMoveTo actionWithDuration:0.1f position:ccp(iDevPixelX(160), y)];
	id changeFunc = [CCCallFunc actionWithTarget:self selector:@selector(changePreviewSprite:)];
	id sequence = [CCSequence actions: aniStartFunc, ease, changeFunc, moveto, backto, backto1, backto2, aniEndFunc, backto3,nil];
	[_sprViewLevel runAction:sequence];
	
	[self setPropertyOfSprites];
}

- (void) setPropertyOfSprites
{
//	if (![AppSettings getLevelFlag:_world])
//	{
//		_sprLock.visible = YES;
//	}
//	else
//	{
//		_sprLock.visible = NO;
//	}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] > 10) {
        g_bTestMode = true;
        _level = [AppSettings getCurLevel:_world];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You enter test mode from now."
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		if (alert) {
			[alert show];
			[alert release];
		}
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if ([touch tapCount] > 1)
		return;
	
	CGPoint location = [touch locationInView:[touch view]];
    location.y = SCREEN_HEIGHT - location.y;
    
    CGRect rt;
    for (int i = 0; i < 3; i ++) {
        for (int j = 0; j < 4; j++) {
            
            rt = CGRectMake(iDevPixelX(FIRSTPOS_X) + j * iDevPixelX(INTERVAL_X) - iDevPixelX(57) / 2,
                            iDevPixelY(FIRSTPOS_Y) - i * iDevPixelY(INTERVAL_Y) - iDevPixelY(53) / 2, 
                            iDevPixelX(57), 
                            iDevPixelY(53));
            if (CGRectContainsPoint(rt, location)) {
                [self gotoGame:_world level:i * 4 + j];
            }
               
        }
    }
}


- (void) actionArrowLeft: (id) sender
{
	[m_soundManager playEffect: soundArrowClick bForce:YES];
	
	_world--;
	if (_world < 0)
		_world = WORLD_COUNT - 1;
    _level = [AppSettings getCurLevel:_world];
    [AppSettings setCurWorld:_world];
    
    if (_world < 3) {
        CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"level_bg_%d.png", _world]];
        [m_spriteBack setTexture:tex];
    }
	[self animateStagePreview];
}

- (void) actionArrowRight: (id) sender
{
	[m_soundManager playEffect: soundArrowClick bForce:YES];
    
	_world = (_world + 1) % WORLD_COUNT;
    _level = [AppSettings getCurLevel:_world];
    [AppSettings setCurWorld:_world];
    
    if (_world < 3) {
        CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"level_bg_%d.png", _world]];
        [m_spriteBack setTexture:tex];
    }
	[self animateStagePreview];
}

- (void) changePreviewSprite: (id) sender
{
    NSString* str;
    switch ([AppSettings getPlayMode]) {
        case MODE_TIME:
            str = [NSString stringWithFormat: @"mt_world%d_preview.png", _world];
            break;
        case MODE_DESTRUCTION:
            str = [NSString stringWithFormat: @"world%d_preview.png", _world];
            break;   
        default:
            break;
    }
	CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:str];
	[_sprViewLevel setTexture:tex];
}

- (void) draw
{
    if (m_bChangeWorldAnimating) {
        return;
    }
    CGPoint pos;
    for (int i = 0; i < 3; i ++) {
        for (int j = 0; j < 4; j++) {            
            pos = ccp(iDevPixelX(FIRSTPOS_X) + j * iDevPixelX(INTERVAL_X), iDevPixelY(FIRSTPOS_Y) - iDevPixelY(INTERVAL_Y) * i);
            
            if (_level < i * 4 + j + 1) {
                [m_sprLock setPosition:pos];
                [m_sprLock visit];
                continue;
            }
            
            CCLabelTTF *lblTmp = m_lblLevel;
            [lblTmp setString:[NSString stringWithFormat:@"%d", i * 4 + j + 1]];
            [lblTmp setPosition:pos];
            [lblTmp visit];
        }
    }
}

-(void) levelBtnClickAnimation:(CCSprite*) pspr {
    [pspr runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.2f scale:1.3f],
                       [CCScaleTo actionWithDuration:0.1f scale:0.8f],
                       [CCScaleTo actionWithDuration:0.07f scale:1.1f],
                        [CCScaleTo actionWithDuration:0.05f scale:1.0f],
                       nil]];
}

-(void) changeWorldAnimationStart {
    m_bChangeWorldAnimating = true;
    for (int i = 0; i < LEVEL_COUNT; i++) {
        [m_sprLevel[i] runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:0.05 scale:0.5], 
                                  [CCFadeOut actionWithDuration:0.2],
                                  nil]];
    }
}

-(void) changeWorldAnimationEnd {
    m_bChangeWorldAnimating = false;
    for (int i = 0; i < LEVEL_COUNT; i++) {
        [m_sprLevel[i] runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:0.05 scale:1.0f], 
                                  [CCFadeIn actionWithDuration:0.2],
                                  nil]];
    }
}

@end
