//
//  StageScene.h
//  Game
//
//  Created by hrh on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScaleLayer.h"
#import "global.h"
#import "SoundManager.h"

@class ResourceManager;
@class GrowButton;
@class AppDelegate;
@class CCLabelFX;

@interface StageScene : ScaleLayer <UIAlertViewDelegate>{
    AppDelegate*	m_app;
	
    ResourceManager*	m_resManager;
    SoundManager*       m_soundManager;
    
	CCSprite*			m_spriteBack;
	CCSprite*           m_sprLock;
    CCSprite*           m_sprLevel[LEVEL_COUNT];
    
    CCLabelFX*          m_lblLevel;
    
	CCSprite*           _sprViewLevel;	
    
	int                 _world;
    int                 _level;
    
    bool                m_bChangeWorldAnimating;
}

@property (nonatomic, retain) CCSprite* sprViewLevel;
@property (nonatomic, retain) GrowButton* unlockMenu;

+ (CCScene*) scene;
- (void) setPropertyOfSprites;
- (void) actionPlay:(id)sender;
-(void) levelBtnClickAnimation:(CCSprite*) pspr;
-(void) changeWorldAnimationStart;
-(void) changeWorldAnimationEnd;
@end
