#import "SettingScene.h"
#import "global.h"
#import "ScaleMenu.h"
#import "ScaleMenuItemToggle.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "TitleScene.h"
#import "EffectStar.h"

@interface SettingScene()
- (void) createEffects;
- (void) createStarEffect: (CGPoint) pos color:(int) color;
@end

@implementation SettingScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SettingScene *layer = [SettingScene node];
	
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
	
	CCSprite * Pan_setting = [CCSprite spriteWithFile:@"setting.png"];
	Pan_setting.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.32);
	[self addChild:Pan_setting];
}

-(void) drawBtns {
	CCMenuItemImage * pBackBtn = [CCMenuItemImage itemFromNormalImage:@"ok_0.png"
														selectedImage:@"ok_1.png"
															   target:self selector:@selector(onBack)];
	pBackBtn.position = ccp(iDevPixelX(160), iDevPixelY(155) - SCREEN_HEIGHT * 0.18);
	
	ScaleMenuItemToggle * pBMEnableBtn= [ScaleMenuItemToggle itemWithTarget:self selector:@selector(onBMEnable:) items:
									  [CCMenuItemImage itemFromNormalImage:@"check_0.png" selectedImage:@"check_0.png" target:self selector:@selector(onBMEnable:)],
									  [CCMenuItemImage itemFromNormalImage:@"check_1.png" selectedImage:@"check_1.png" target:self selector:@selector(onBMEnable:)],
									  nil];
	ScaleMenuItemToggle * pEMEnableBtn= [ScaleMenuItemToggle itemWithTarget:self selector:@selector(onEMEnable:) items:
									  [CCMenuItemImage itemFromNormalImage:@"check_0.png" selectedImage:@"check_0.png" target:self selector:@selector(onEMEnable:)],
									  [CCMenuItemImage itemFromNormalImage:@"check_1.png" selectedImage:@"check_1.png" target:self selector:@selector(onEMEnable:)],
									  nil];
	//pEMEnableBtn.position = ccp(243, 119);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pBMEnableBtn.position = ccp(iDevPixelX(243), iDevPixelY(160));
        pEMEnableBtn.position = ccp(iDevPixelX(243), iDevPixelY(121));
    }
    else {
        pBMEnableBtn.position = ccp(iDevPixelX(280), iDevPixelY(255) - SCREEN_HEIGHT * 0.18);
        pEMEnableBtn.position = ccp(iDevPixelX(280), iDevPixelY(200) - SCREEN_HEIGHT * 0.18);
    }    
	
	ScaleMenu * Menu = [ScaleMenu menuWithItems:pBackBtn, pBMEnableBtn, pEMEnableBtn, nil];
	Menu.position = CGPointZero;
	[self addChild:Menu];
	
	if ([AppSettings isBGMEnable]) {
		pBMEnableBtn.selectedIndex = 1;
	}
	if ([AppSettings isEMEnable]) {
		pEMEnableBtn.selectedIndex = 1;
	}
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

-(void) onBMEnable:(id)sender {
	if ([sender selectedIndex] == 0) {
		[AppSettings setBGMEnable:false];
        [m_soundManager setBackgroundMusicMute:![AppSettings isBGMEnable]];
		[m_soundManager stopBackgroundMusic];
	}
	else {
		[AppSettings setBGMEnable:true];
        [m_soundManager setBackgroundMusicMute:![AppSettings isBGMEnable]];
		[m_soundManager playBackgroundMusic:soundMenuBGM];
	}
}

-(void) onEMEnable:(id)sender {
	if ([sender selectedIndex] == 0) {
		[AppSettings setEMEnable:false];
	}
	else {
		[AppSettings setEMEnable:true];
	}
	[m_soundManager setEffectMute:![AppSettings isEMEnable]];
}

-(void) dealloc {
//	g_GameSetting.saveGameSetting();
	[super dealloc];
}

@end
