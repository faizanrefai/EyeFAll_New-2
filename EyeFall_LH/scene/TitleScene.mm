//
//  TitleScene.mm
//  towerGame
//
//  Created by KCU on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TitleScene.h"
#import "ModeScene.h"
#import "SettingScene.h"
#import "StageScene.h"
#import "CCButton.h"
#import "CCZoomButton.h"
#import "ScoreManager.h"
#import "EffectStar.h"
#import "AppSettings.h"


@interface TitleScene()
- (void) loadResource;
- (void) unloadResource;
- (void) createButtons;
- (void) createEffects;
- (void) createStarEffect: (CGPoint) pos color:(int) color;
@end

// normal
// select
// logo

@implementation TitleScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	TitleScene *layer = [TitleScene node];
	[scene addChild: layer];
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init] )) 
	{
        winSize = [[CCDirector sharedDirector] winSize];
		m_app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_soundManager = [SoundManager sharedSoundManager];
		
        if (![m_soundManager isBackgroundMusicPlaying]) {
            [m_soundManager playBackgroundMusic:soundMenuBGM];
        }
                
		[self loadResource];
		
		[self createButtons];
//		[self createEffects];
        
        
        CCSprite *chicken1 = [CCSprite spriteWithFile:@"idle-chicken1.png"];
        chicken1.position = ccp(winSize.width / 2 + 70, 40);
        chicken1.scale = 1.5;
        [self addChild:chicken1 z:4];
        
        CCSprite *chicken2 = [CCSprite spriteWithFile:@"idle-chicken1.png"];
        chicken2.position = ccp(winSize.width / 2 - 100, 40);
        chicken2.scale = 1.5;
        [self addChild:chicken2 z:4];

        CCSprite *chicken3 = [CCSprite spriteWithFile:@"idle-chicken1.png"];
        chicken3.position = ccp(winSize.width / 2 - 70, 40);
        chicken3.scale = 1.5;
        [self addChild:chicken3 z:4];
	}
	
	return self;
}

- (void) dealloc
{
	[self removeAllChildrenWithCleanup: YES];
	
	[self unloadResource];
	
	[super dealloc];
}

#pragma mark
-(void)spaceAnimate
{
//    CCAnimate *animateSpace = [self space_animation];
//    CCRepeatForever *animAction=[CCRepeatForever actionWithAction:animateSpace];
//    [spaceSprite runAction:animAction];
}

-(CCAnimate *)space_animation
{
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache addSpriteFramesWithFile:@"NewSpaceAtlas.plist"];
    
    // frame array
    NSMutableArray *framesArray=[NSMutableArray array];
    for (int i=1; i<=5; i++)
    {
        NSString *frameName=[NSString stringWithFormat:@"%d.png",i];
        id frameObject=[cache spriteFrameByName:frameName];
        [framesArray addObject:frameObject];
    }
	
    id animObject=[CCAnimation animationWithFrames:framesArray delay:0.1];
    CCAnimate *animAction=[CCAnimate actionWithAnimation:animObject restoreOriginalFrame:NO];
    
	return animAction;
	[framesArray release];
}


#pragma mark Facebook / Game Center
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
    
    [m_app OnFacebookClicked:[AppSettings getTotalMAXScore]];
}

-(void) onGameCenter {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
    [m_app showLeaderboard];
}

- (void) loadResource
{
	m_spriteBack = [CCSprite spriteWithFile:@"title_bg.png"];
    m_spriteBack.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self addChild:m_spriteBack];
    
//    CCSprite* sprBtnBG = [CCSprite spriteWithFile:@"logo_btn_bg.png"];
//    sprBtnBG.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.25);
//    [self addChild:sprBtnBG];
    
    CCSprite *cloudSprite1 = [CCSprite spriteWithFile:@"cloud1_main.png"];
    cloudSprite1.position = ccp(SCREEN_WIDTH / 2 + 90, SCREEN_HEIGHT / 2 + 40);
    [self addChild:cloudSprite1];
    
    CCSprite *cloudSprite2 = [CCSprite spriteWithFile:@"cloud2_main.png"];
    cloudSprite2.position = ccp(SCREEN_WIDTH / 2 - 70, SCREEN_HEIGHT /2 + 40);
    [self addChild:cloudSprite2];
    
    CCSprite *cloudSprite3 = [CCSprite spriteWithFile:@"cloud3_main.png"];
    cloudSprite3.position = ccp(SCREEN_WIDTH / 2 + 10, SCREEN_HEIGHT /2 - 45);
    [self addChild:cloudSprite3];
    
    CCSprite *titleMain = [CCSprite spriteWithFile:@"title_main.png"];
    titleMain.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT /2 + 125);
    titleMain.scale = 0.8;
    [self addChild:titleMain];
}

- (void) unloadResource
{
	
}

- (void) createButtons
{
    CCSprite *spritePlay = [CCSprite spriteWithFile:@"newgame_0.png"];
    CCSprite *spritePlaySel = [CCSprite spriteWithFile:@"newgame_1.png"];
    
    CCMenuItemSprite *menuSprite = [CCMenuItemSprite itemFromNormalSprite:spritePlay selectedSprite:spritePlaySel target:self selector:@selector(onPlayGame:)];
    CCMenu *playMenu  = [CCMenu menuWithItems:menuSprite, nil];
    playMenu.position = ccp(winSize.width / 2, 70);
    [self addChild:playMenu];
    
    CCSprite *spriteFacebook = [CCSprite spriteWithFile:@"btn_facebook.png"];
    CCSprite *spriteFbSel = [CCSprite spriteWithFile:@"btnPressed-facebook_modeSelect.png"];
    CCMenuItemSprite *menuSpriteFb = [CCMenuItemSprite itemFromNormalSprite:spriteFacebook selectedSprite:spriteFbSel target:self selector:@selector(onFacebook)];
    
    CCSprite *spriteGame = [CCSprite spriteWithFile:@"btn_onlinescore.png"];
    CCSprite *spriteGameSel = [CCSprite spriteWithFile:@"btnPressed-onlineScore_modeSelect.png"];
    CCMenuItemSprite *menuSpriteGame = [CCMenuItemSprite itemFromNormalSprite:spriteGame selectedSprite:spriteGameSel target:self selector:@selector(onGameCenter)];

    CCMenu *buttonsMenu  = [CCMenu menuWithItems:menuSpriteFb, menuSpriteGame, nil];
    buttonsMenu.position = ccp(winSize.width - 30 , 60);
    [buttonsMenu alignItemsVerticallyWithPadding:5.0];
    [self addChild:buttonsMenu];
    
    
//	CCZoomButton* btn;
//	btn = [[CCZoomButton alloc] initWithFullPath: self
//									  selector: @selector(onPlayGame:)
//								   textureName: @"newgame_0.png"
//								selTextureName: @"newgame_1.png"
//									  textName: nil
//									  position: ccp(iDevPixelX(98), iDevPixelY(325))
//									 afterTime: 0.4f];
//	[self addChild: btn];
	
//	btn = [[CCZoomButton alloc] initWithFullPath: self
//									  selector: @selector(onSetting:)
//								   textureName: @"setting_0.png"
//								selTextureName: @"setting_1.png"
//									  textName: nil
//									  position: ccp(iDevPixelX(109), iDevPixelY(365))
//									 afterTime: 0.8f];
//	[self addChild: btn];
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

-(void) onPlayGame:(id)sender {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
#ifdef USE_LOADING_SCENE
    [m_app changeWindow:WND_MODE];
#else
//    CCScene * scene = [ModeScene node];
    CCScene * scene = [StageScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

-(void) onSetting:(id)sender {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
#ifdef USE_LOADING_SCENE
    [m_app changeWindow:WND_SETTING];
#else
    CCScene * scene = [SettingScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

@end
