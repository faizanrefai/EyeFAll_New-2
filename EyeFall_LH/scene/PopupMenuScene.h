#import "cocos2d.h"
#import "ScaleLayer.h"
#import <Foundation/Foundation.h>
#import "SoundManager.h"

@class AppDelegate;
@class GrowButton;

@interface PopupMenuScene : ScaleLayer {
	AppDelegate*        m_pApp;
    SoundManager*       m_soundManager;
    
    int                    m_nworld;
    int                    m_nlevel;
    
    GrowButton*         m_pPauseBtn;
    GrowButton*         m_pPlayBtn;
}

+(CCScene *) scene;
-(id)   initWithParameters:(int)world level:(int)level;

-(void) drawImages;
-(void) drawBtns;

-(void)	onBack;
-(void) onRetry;
-(void) onPause;
-(void) onPlay;

@end

