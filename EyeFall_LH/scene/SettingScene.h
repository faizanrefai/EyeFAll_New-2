#import "cocos2d.h"
#import "ScaleLayer.h"
#import <Foundation/Foundation.h>
#import "SoundManager.h"

@class AppDelegate;

@interface SettingScene : ScaleLayer {
	AppDelegate*        m_pApp;
    SoundManager*       m_soundManager;
}

+(CCScene *) scene;

-(void) drawImages;
-(void) drawBtns;

-(void)	onBack;
-(void) onBMEnable:(id)sender;
-(void) onEMEnable:(id)sender;

@end

