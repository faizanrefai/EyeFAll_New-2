//
//  GameSuccessScene.h
//  hotair
//
//  Created by admin on 12/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScaleLayer.h"
#import "CCLabelFX.h"
#import "AppDelegate.h"
#import "SoundManager.h"

enum SuccessLayerState {
	stateStart = 50,
	stateTimeAnimating,
	stateTimeComplete,
	stateTBAnimating,
	stateTBComplete,
	stateBonusAnimating,
	stateBonusComplete,
	stateEnd,
};

@interface GameSuccessScene : ScaleLayer {
    int     m_nworld;
    int     m_nlevel;
    int     m_nNextWorld;
    int     m_nNextLevel;
    int     m_nRemainEyes;
    
    AppDelegate*        m_pApp;
    SoundManager*       m_soundManager;
    
	CCLabelFX *			m_pTimeBonusLbl;
	CCLabelFX *			m_pBonusLabel;
	
	int					m_nBonus;
	SuccessLayerState	m_nState;
	double				m_actionStartTime;
	
	CGPoint				m_ptBackground;
}

-(id)   initWithParameters:(int)world level:(int)level remainEyes:(int)remainEyes;
-(void) drawImages;
-(void) drawLabels;
-(void) drawBtns;

-(void)	onContinue;
-(void)	onToMenu;

-(void) addEmitter:(CGPoint)ptPos;
-(void) addBackEmitter;

-(void) timeLabelAnimation;

-(NSString*) getTimeString:(double)fTime;

-(void)			onTimer;

@end

