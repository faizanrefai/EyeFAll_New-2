//
//  GameOverScene.h
//  hotair
//
//  Created by admin on 12/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScaleLayer.h"
#import "AppDelegate.h"
#import "SoundManager.h"

@interface GameOverScene : ScaleLayer {
    int     m_nworld;
    int     m_nlevel;
    AppDelegate*        m_pApp;
    SoundManager*       m_soundManager;
    
    CGPoint				m_ptBackground;
}

-(id)   initWithParameters:(int)world level:(int)level;
-(void) drawImages;
-(void) drawLabels;
-(void) drawBtns;

-(void)	onReplay;
-(void)	onToMenu;

@end
