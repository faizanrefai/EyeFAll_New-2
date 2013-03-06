#import "cocos2d.h"
#import "CCLabelFX.h"
#import "ScaleLayer.h"
#import "AppDelegate.h"

#import <Foundation/Foundation.h>



@interface GameEndScene : ScaleLayer {
    AppDelegate*        m_pApp;
    
    int     m_nworld;
    int     m_nlevel;
    int     m_nRemainEyes;
    
	CCLabelFX *			m_pTimeLbl;
	CCLabelFX *			m_pTimeBonusLbl;
	CCLabelFX *			m_pBonusLabel;
	
	int					m_nBonus;
	double				m_fParticle;
	
	CGPoint				m_ptBackground;
}

+(CCScene *) scene;

-(id)   initWithParameters:(int)world level:(int)level remainEyes:(int)remainEyes;

-(void) drawImages;
-(void) drawLabels;
-(void) drawBtns;

-(void)	onNewGame;
-(void)	onToMenu;

-(void) addEmitter;
-(void) addBackEmitter;

-(void)	onTimer:(ccTime)dt;
@end

