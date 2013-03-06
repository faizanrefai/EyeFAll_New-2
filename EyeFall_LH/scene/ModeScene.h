#import "cocos2d.h"
#import "ScaleLayer.h"
#import <Foundation/Foundation.h>
#import "SoundManager.h"

@class AppDelegate;

@interface ModeScene : ScaleLayer {
	AppDelegate*        m_pApp;
    SoundManager*       m_soundManager;
}

+(CCScene *) scene;

-(void) drawImages;
-(void) drawBtns;

-(void)	onBack;
-(void) onDestructionMode;
-(void) onTimeMode;
-(void) onFacebook;
-(void) onShutUp;
@end

