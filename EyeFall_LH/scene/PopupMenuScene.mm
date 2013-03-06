#import "PopupMenuScene.h"
#import "global.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "EffectStar.h"
#import "StageScene.h"
#import "GrowButton.h"
#import "GameScene.h"

@interface PopupMenuScene()
- (void) createEffects;
- (void) createStarEffect: (CGPoint) pos color:(int) color;
@end

@implementation PopupMenuScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PopupMenuScene *layer = [PopupMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)   initWithParameters:(int)world level:(int)level {
    if((self = [super init])){
        self.isTouchEnabled = true;
        m_pApp = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_soundManager = [SoundManager sharedSoundManager];
        
        m_nworld = world;
        m_nlevel = level;
        
        [self drawImages];
		//[self addBackEmitter];
		[self drawBtns];
		
    }
    return self;
}

-(void) drawImages {
	CCSprite * background = [CCSprite spriteWithFile:@"pan_game_menu.png"];
	background.position = CGPointZero;//
	[self addChild:background];
}

-(void) drawBtns {
	GrowButton * pBackBtn = [GrowButton buttonWithSprite: @"level.png"
                                             selectImage: @"level.png"
                                                  target: self
                                                selector: @selector(onBack)];
	pBackBtn.position =  ccp(iDevPixelX(-50), -iDevPixelY(1));
	[self addChild:pBackBtn];
    
    m_pPauseBtn = [GrowButton buttonWithSprite: @"pause.png"
                                             selectImage: @"pause.png"
                                                  target: self
                                                selector: @selector(onPause)];
	m_pPauseBtn.position =  ccp(iDevPixelX(0), -iDevPixelY(1));
	[self addChild:m_pPauseBtn];
    
    m_pPlayBtn = [GrowButton buttonWithSprite: @"play.png"
                                              selectImage: @"play.png"
                                                   target: self
                                                 selector: @selector(onPlay)];
	m_pPlayBtn.position =  ccp(iDevPixelX(0), -iDevPixelY(1));
	[self addChild:m_pPlayBtn];
    [m_pPlayBtn setVisible:NO];
    
    GrowButton * pRetryBtn = [GrowButton buttonWithSprite: @"retry.png"
                                             selectImage: @"retry.png"
                                                  target: self
                                                selector: @selector(onRetry)];
	pRetryBtn.position =  ccp(iDevPixelX(50), -iDevPixelY(1));
	[self addChild:pRetryBtn];
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
    
//#ifdef USE_LOADING_SCENE
    [m_pApp changeWindow:WND_LEVEL];
//#else
//    CCScene * scene = [StageScene node];
//    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
//    [[CCDirector sharedDirector] replaceScene: ts];
//#endif  //USE_LOADING_SCENE
}

-(void) onRetry {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_pApp changeWindow:WND_GAME param1:m_nworld param2:m_nlevel];
}

-(void) onPause {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_pPauseBtn setVisible:NO];
    [m_pPlayBtn setVisible:YES];
    GameScene* pParent = (GameScene*)[self parent];
    if (pParent) {
        [pParent onPause:true];
    }
}

-(void) onPlay {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_pPauseBtn setVisible:YES];
    [m_pPlayBtn setVisible:NO];
    GameScene* pParent = (GameScene*)[self parent];
    if (pParent) {
        [pParent onPause:false];
        [pParent PopupMenuAnimation:false];
    }
}

-(void) dealloc {
//	g_GameSetting.saveGameSetting();
	[super dealloc];
}

@end
