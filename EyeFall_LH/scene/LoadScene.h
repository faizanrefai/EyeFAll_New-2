//
//  GameScene.h
//  towerGame
//
//  Created by KCU on 6/13/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "global.h"
#import "ScaleLayer.h"
#import "SoundManager.h"

// HelloWorld Layer
@interface LoadScene : ScaleLayer
{
	CCSprite* m_sprloading;
    
    WND_ID	m_nCurWnd;
    WND_ID  m_nNewWnd;
    int     m_nParam1;
    int     m_nParam2;
    
    long    m_tick;
    
    SoundManager*       m_soundManager;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene:(WND_ID) wndCur wndNew:(WND_ID) wndNew param:(int) param;
+(id) scene:(WND_ID) wndCur wndNew:(WND_ID) wndNew param1:(int) param1 param2:(int) param2;

- (id)   initWithParameters:(WND_ID) wndCur wndNew:(WND_ID) wndNew param:(int) param;
- (id)   initWithParameters:(WND_ID) wndCur wndNew:(WND_ID) wndNew param1:(int) param1 param2:(int) param2;
- (void) changeWindow;
@end
