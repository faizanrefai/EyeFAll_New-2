//
//  GameOverScene.m
//  hotair
//
//  Created by admin on 12/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameOverScene.h"
#import "ScaleMenu.h"
#import "CCLabelFX.h"
#import "StageScene.h"
#import "AppSettings.h"

@implementation GameOverScene

-(id)   initWithParameters:(int)world level:(int)level {
    if((self = [super init])){
        self.isTouchEnabled = true;
        m_pApp = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_soundManager = [SoundManager sharedSoundManager];
        [m_soundManager playEffect:soundFail loop:NO];
        
        m_nworld = world;
        m_nlevel = level;
        
        [self drawImages];
		//[self addBackEmitter];
		[self drawLabels];
		[self drawBtns];
		
    }
    return self;
}

-(void) drawImages {
	CGSize size = [[CCDirector sharedDirector] winSize];
	m_ptBackground = ccp(size.width / 2, size.height);
	
	CCSprite * back = [CCSprite spriteWithFile:@"trans_back.png"];
	back.position = m_ptBackground;
	back.scale = 3.0f;
	back.opacity = 128.0f;
	[self addChild:back];
	
	CCSprite * background = [CCSprite spriteWithFile:@"game_over.png"];
	background.position = m_ptBackground;
	[self addChild:background];
}

-(void) drawBtns {
	CCMenuItemImage * pReplayBtn = [CCMenuItemImage itemFromNormalImage:@"replay_0.png"
                                                          selectedImage:@"replay_1.png"
                                                                 target:self selector:@selector(onReplay)];
	pReplayBtn.position = ccpAdd(m_ptBackground, ccp(54, -63));
	//pReplayBtn.scale = 0;
	
	CCMenuItemImage * pToMenuBtn = [CCMenuItemImage itemFromNormalImage:@"back_level_0.png"
														  selectedImage:@"back_level_1.png"
																 target:self selector:@selector(onToMenu)];
	pToMenuBtn.position = ccpAdd(m_ptBackground, ccp(-50, -63));
	//pToMenuBtn.scale = 0;
	
	ScaleMenu * Menu = [ScaleMenu menuWithItems:pReplayBtn, pToMenuBtn, nil];
	Menu.position = CGPointZero;
	[self addChild:Menu];
	
	//[pReplayBtn runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
	//[pToMenuBtn runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
}

-(void) drawLabels {
	
	ccColor3B lblColor = ccc3(0, 0, 0);
	float lblFontSize = 32;
	
	CCLabelFX* pStageLbl = [CCLabelFX labelWithString:[NSString stringWithFormat:@"STA GE%d", m_nlevel + 1] fontName:g_strFontName1 fontSize:lblFontSize
										 shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pStageLbl];
	pStageLbl.position = ccpAdd(m_ptBackground, ccp(0, 15));
	pStageLbl.shadowColor = ccc4(0, 0, 255, 0);
	pStageLbl.color = lblColor;
    
    CCLabelFX* pBonusLbl = [CCLabelFX labelWithString:@"High Score" fontName:g_strFontName fontSize:17
                                         shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pBonusLbl];
	pBonusLbl.position = ccpAdd(m_ptBackground, ccp(-40, -22));
	pBonusLbl.shadowColor = ccc4(255, 0, 0, 0);
	pBonusLbl.color = lblColor;
	
	CCLabelFX* m_pBonusLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"%d", [AppSettings getScore:m_nworld nlevel:m_nlevel]] fontName:g_strFontName fontSize:17
                                  shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:m_pBonusLabel];
	m_pBonusLabel.position = ccpAdd(m_ptBackground, ccp(55, -22));
	m_pBonusLabel.color = lblColor;
	m_pBonusLabel.shadowColor = ccc4(255, 0, 0, 0);
}

-(void) onReplay {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
	[m_pApp changeWindow:WND_GAME param1:m_nworld param2:m_nlevel];
}

-(void)	onToMenu {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
	[m_pApp changeWindow:WND_LEVEL];
}

-(void) dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}
@end
