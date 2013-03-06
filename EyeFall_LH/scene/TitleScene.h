//
//  TitleScene.h
//  towerGame
//
//  Created by KCU on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ResourceManager.h"
#import "ScaleLayer.h"
#import "SoundManager.h"

@class AppDelegate;

@interface TitleScene : ScaleLayer 
{
    CGSize winSize;
    AppDelegate*	m_app;

	ResourceManager*	m_resManager;
    SoundManager*       m_soundManager;
    
	CCSprite*			m_spriteBack;
}

+(id) scene;
-(id) init;

-(void) onPlayGame:(id)sender;
-(void) onSetting:(id)sender;
@end
