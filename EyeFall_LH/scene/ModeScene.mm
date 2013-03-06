#import "ModeScene.h"
#import "global.h"
#import "ScaleMenu.h"
#import "ScaleMenuItemToggle.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "GrowButton.h"
#import "GrowScaleButton.h"
#import "StageScene.h"
#import "TitleScene.h"
#import "EffectStar.h"

@interface ModeScene()
- (void) createEffects;
- (void) createStarEffect: (CGPoint) pos color:(int) color;
@end

@implementation ModeScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ModeScene *layer = [ModeScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	self=[super init];
	if( self != 0 ) {
        m_pApp = (AppDelegate*)[[UIApplication sharedApplication] delegate];      
        m_soundManager = [SoundManager sharedSoundManager];
        
		[self drawImages];
		[self drawBtns];
        [self createEffects];
	}
	return self;
}

-(void) drawImages {
	CCSprite * background = [CCSprite spriteWithFile:@"title_bg.png"];
	background.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	[self addChild:background];
}

-(void) drawBtns {
	GrowButton *btnBack;
	btnBack = [GrowButton buttonWithSprite: @"level_back_0.png"
                           selectImage: @"level_back_0.png"
                                target: self
                              selector: @selector(onBack)];
	btnBack.position =  ccp(iDevPixelX(30), iDevPixelY(450));
	[self addChild:btnBack];
    
    GrowScaleButton* btn = [GrowScaleButton buttonWithSprite: @"mode_destruction.png"
                           selectImage: @"mode_destruction.png"
                                target: self
                              selector: @selector(onDestructionMode)];
	btn.position =  ccp(iDevPixelX(80), iDevPixelY(120));
	[self addChild:btn];
    
    btn = [GrowScaleButton buttonWithSprite: @"mode_time.png"
                           selectImage: @"mode_time.png"
                                target: self
                              selector: @selector(onTimeMode)];
	btn.position =  ccp(iDevPixelX(225), iDevPixelY(120));
	[self addChild:btn];
    
    btn = [GrowScaleButton buttonWithSprite: @"btn_facebook.png"
                           selectImage: @"btn_facebook.png"
                                target: self
                              selector: @selector(onFacebook)];
	btn.position =  ccp(iDevPixelX(175), iDevPixelY(30));
	[self addChild:btn];
    
    btn = [GrowScaleButton buttonWithSprite: @"btn_shutup.png"
                           selectImage: @"btn_shutup.png"
                                target: self
                              selector: @selector(onShutUp)];
	btn.position =  ccp(iDevPixelX(230), iDevPixelY(30));
	[self addChild:btn];
    
    btn = [GrowScaleButton buttonWithSprite: @"btn_onlinescore.png"
                           selectImage: @"btn_onlinescore.png"
                                target: self
                              selector: @selector(onGameCenter)];
	btn.position =  ccp(iDevPixelX(285), iDevPixelY(30));
	[self addChild:btn];
}


- (void) createEffects
{
	[self createStarEffect: ccp(iDevPixelX(10), iDevPixelY(350)) color:cBlue];
	[self createStarEffect: ccp(iDevPixelX(60), iDevPixelY(300)) color:cYellow];
	[self createStarEffect: ccp(iDevPixelX(150), iDevPixelY(390)) color:cBlue];
	[self createStarEffect: ccp(iDevPixelX(215), iDevPixelY(363)) color:cYellow];
}

- (void) createStarEffect: (CGPoint) pos color:(int) color
{
	EffectStar* star = [EffectStar node];
	star.position = pos;
	[star setColor: color];
	[self addChild: star z: 2];
}

-(void)	onBack {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
#ifdef USE_LOADING_SCENE
    [m_app changeWindow:WND_TITLE];
#else
    CCScene * scene = [TitleScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

-(void) onDestructionMode {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [AppSettings setPlayMode:MODE_DESTRUCTION];
#ifdef USE_LOADING_SCENE
    [m_app changeWindow:WND_LEVEL];
#else
    CCScene * scene = [StageScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

-(void) onTimeMode {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [AppSettings setPlayMode:MODE_TIME];
#ifdef USE_LOADING_SCENE
    [m_app changeWindow:WND_LEVEL];
#else
    CCScene * scene = [StageScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

-(void) onFacebook {
    
    if (g_bTestMode) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You can't open facebook in test mode.\nPlease restart game."
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		if (alert) {
			[alert show];
			[alert release];
		}
        return;
    }
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_pApp OnFacebookClicked:[AppSettings getTotalMAXScore]];
}

-(void) onShutUp {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.Shutupsystems.com"]];
}

-(void) onGameCenter {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_pApp showLeaderboard];
}

-(void) dealloc {
	[super dealloc];
}

@end
