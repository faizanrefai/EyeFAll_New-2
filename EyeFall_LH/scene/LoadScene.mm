//
//  GameScene.m
//  towerGame
//
//  Created by KCU on 6/13/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "AppDelegate.h"
#import "AppSettings.h"
#import "ResourceManager.h"
#import "SoundManager.h"
#import "LoadScene.h"
#import "AnimationManager.h"
#import "GameScene.h"
#import "StageScene.h"
#import "TitleScene.h"
#import "SettingScene.h"
#import "ModeScene.h"

/*
#import "QuickGame.h"
#import "GameLogic.h"
 */

@interface LoadScene()
- (void) initGameSetting;
- (void) loadResource;
- (void) unloadResource;
@end

@implementation LoadScene

+(id) scene:(WND_ID) wndCur wndNew:(WND_ID) wndNew param:(int) param
{
	CCScene *scene = [CCScene node];
	LoadScene *layer = [[[LoadScene alloc] initWithParameters:wndCur wndNew:wndNew param:param] autorelease];
    //LoadScene *layer = [LoadScene node]; 
	[scene addChild: layer];
    
   	return scene;
}

+(id) scene:(WND_ID) wndCur wndNew:(WND_ID) wndNew param1:(int) param1 param2:(int) param2
{
	CCScene *scene = [CCScene node];
	LoadScene *layer = [[[LoadScene alloc] initWithParameters:wndCur wndNew:wndNew param1:param1 param2:param2] autorelease];
    //LoadScene *layer = [LoadScene node]; 
	[scene addChild: layer];
    
   	return scene;
}

- (id)   initWithParameters:(WND_ID) wndCur wndNew:(WND_ID) wndNew param:(int) param 
{
	if( (self=[super init] )) 
	{    
        m_nCurWnd = wndCur;
        m_nNewWnd = wndNew;
        m_nParam1 = param;
        
        m_tick = 0;
        
        m_soundManager = [SoundManager sharedSoundManager];
        
//		m_sprloading = [CCSprite spriteWithFile:@"loading.png"];
        
        m_sprloading = [CCSprite spriteWithFile:@"Loading1.png"];
        [m_sprloading setPosition: ccp(iDevPixelX(160), iDevPixelY(240))];
        [self addChild:m_sprloading];
		[self initGameSetting];
        
        if (![m_soundManager isBackgroundMusicPlaying]) {
            [m_soundManager playBackgroundMusic:soundMenuBGM];
        }
	}
	return self;
}

- (id)   initWithParameters:(WND_ID) wndCur wndNew:(WND_ID) wndNew param1:(int) param1 param2:(int) param2
{
	if( (self=[super init] )) 
	{    
        m_nCurWnd = wndCur;
        m_nNewWnd = wndNew;
        m_nParam1 = param1;
        m_nParam2 = param2;
        
        m_tick = 0;
        
		m_soundManager = [SoundManager sharedSoundManager];
        
        m_sprloading = [CCSprite spriteWithFile:@"Loading1.png"]; //[CCSprite spriteWithFile:@"loading.png"];
        [m_sprloading setPosition: ccp(iDevPixelX(160), iDevPixelY(240))];
        [self addChild:m_sprloading];
        
		[self initGameSetting];
        
        if (![m_soundManager isBackgroundMusicPlaying]) {
            [m_soundManager playBackgroundMusic:soundMenuBGM];
        }
	}
	return self;
}

- (void) dealloc
{
	[self unloadResource];
	
	[super dealloc];
}

- (void) loadResource
{
    
}

- (void) unloadResource
{
	
}

- (void) initGameSetting
{
    if (m_nCurWnd != WND_NONE) {
        return;
    }
    [AppSettings defineUserDefaults];
}

- (void) draw
{
	m_tick ++;
	
	if (m_tick > 1)
	{
		//CCLabelBMFont* font = m_resManager.shadowFont;
		
		 if (m_tick == 40) {
             [[CCTextureCache sharedTextureCache] removeUnusedTextures];
             
             [self loadResource];
             [self changeWindow];
        }
	}	
}
             
- (void) changeWindow {
    CCDirector*	director = [CCDirector sharedDirector];
    CCScene*	scene = nil;
	
    switch ( m_nNewWnd ) {
        case WND_TITLE:
            scene = [TitleScene node];
            break;
        case WND_MODE:
            scene = [ModeScene node];
            break;
        case WND_LEVEL:
            scene = [StageScene node];
            break;
        case WND_SETTING:
            scene = [SettingScene node];
            break;
        case WND_GAME:
            scene = [GameScene scene:m_nParam1 level:m_nParam2];
            break;
        default:
			break;
    }
    
    if( scene ) {
		CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
		[director replaceScene: ts];
    }
}

@end
