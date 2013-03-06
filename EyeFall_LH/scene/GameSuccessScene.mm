//
//  GameSuccessScene.m
//  hotair
//
//  Created by admin on 12/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameSuccessScene.h"
#import "ScaleMenu.h"
#import "AppSettings.h"
#import "StageScene.h"


@implementation GameSuccessScene
-(id)   initWithParameters:(int)world level:(int)level remainEyes:(int)remainEyes {
    if((self = [super init])){
        m_nworld = world;
        m_nlevel = level;
        m_nRemainEyes = remainEyes;
        
        if (m_nlevel >= LEVEL_COUNT - 1) {
            
            if (m_nworld == 2) {
                //game end
            }
            else {
                m_nNextWorld = m_nworld + 1;
                m_nNextLevel = 0;
                if ([AppSettings getCurLevel:m_nNextWorld] == 0) {
                    [AppSettings setCurLevel:m_nNextWorld level:1];
                }
                else {
                    
                }
            }
        }
        else {
            m_nNextWorld = m_nworld;
            m_nNextLevel = m_nlevel + 1;
            [AppSettings setCurLevel:m_nNextWorld level:m_nNextLevel + 1];
        }
        
        self.isTouchEnabled = true;
        m_pApp = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_soundManager = [SoundManager sharedSoundManager];
        [m_soundManager playEffect:soundSuccess loop:NO];
        
        m_nBonus = 0;
        
		[self drawImages];
		[self addBackEmitter];
		[self drawLabels];
		
        [self schedule:@selector(BonusAnimate:) interval:0.1f];
        [self schedule:@selector(onTimer) interval:0.1];
        
		m_nState = stateStart;
        
		//[[SoundManager sharedSoundManager] playBackgroundMusic:soundMenuBGM];
		
		m_actionStartTime = (NSTimeInterval)[NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (void) BonusAnimate:(ccTime)dt {
    if (m_nState == stateTimeComplete) {
        if (m_nBonus == 0) {
            [m_pTimeBonusLbl setVisible:YES];
            [m_pTimeBonusLbl setString:[NSString stringWithFormat:@"%d", m_nBonus]];
        }
        if (m_nRemainEyes == -1) {
            m_nState = stateTBAnimating;
            m_actionStartTime = (NSTimeInterval)[NSDate timeIntervalSinceReferenceDate];
            [self addEmitter:[m_pTimeBonusLbl position]];
            
            m_nBonus += [AppSettings getScore:m_nworld nlevel:m_nlevel];
            [AppSettings setScore:m_nworld nlevel:m_nlevel nScore:m_nBonus];
            [m_pApp submitScore:m_nBonus];
        }
        else {
            m_nBonus += 1000;
            [m_pTimeBonusLbl setString:[NSString stringWithFormat:@"%d", m_nBonus]];
            m_nRemainEyes--;
        }
    }
}

-(void) drawImages {
	CGSize size = [[CCDirector sharedDirector] winSize];
	m_ptBackground = ccp(size.width / 2, size.height);
	
	CCSprite * back = [CCSprite spriteWithFile:@"trans_back.png"];
	back.position = m_ptBackground;
	back.scale = 3.0f;
	back.opacity = 128.0f;
	[self addChild:back];
	
	CCSprite * background = [CCSprite spriteWithFile:@"level_succss.png"];
	background.position = m_ptBackground;
	[self addChild:background];
}

-(void) drawBtns {
	CCMenuItemImage * pContinueBtn = [CCMenuItemImage itemFromNormalImage:@"next_play_0.png"
															selectedImage:@"next_play_1.png"
																   target:self selector:@selector(onContinue)];
	pContinueBtn.position = ccpAdd(m_ptBackground, ccp(54, -70));
	pContinueBtn.scale = 0;
    
	CCMenuItemImage * pToMenuBtn = [CCMenuItemImage itemFromNormalImage:@"back_level_0.png"
														  selectedImage:@"back_level_1.png"
																 target:self selector:@selector(onToMenu)];
	pToMenuBtn.position = ccpAdd(m_ptBackground, ccp(-50, -70));
	pToMenuBtn.scale = 0;
	
	ScaleMenu * Menu = [ScaleMenu menuWithItems:pContinueBtn, pToMenuBtn, nil];
	Menu.position = CGPointZero;
	[self addChild:Menu];
	
    if (CC_CONTENT_SCALE_FACTOR() != 2) {
        [pContinueBtn runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.4 scale:iDevSize(0.6)],
                                 [CCScaleTo actionWithDuration:0.2 scale:iDevSize(0.45)],
                                 [CCScaleTo actionWithDuration:0.1 scale:iDevSize(0.525)],
                                 [CCScaleTo actionWithDuration:0.05 scale:iDevSize(0.5)], nil]];
        [pToMenuBtn runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.4 scale:iDevSize(0.6)],
                                  [CCScaleTo actionWithDuration:0.2 scale:iDevSize(0.45)],
                                  [CCScaleTo actionWithDuration:0.1 scale:iDevSize(0.525)],
                                  [CCScaleTo actionWithDuration:0.05 scale:iDevSize(0.5)], nil]];
    }
    else {
        [pContinueBtn runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.4 scale:iDevSize(1.2)],
                                 [CCScaleTo actionWithDuration:0.2 scale:iDevSize(0.9)],
                                 [CCScaleTo actionWithDuration:0.1 scale:iDevSize(1.05)],
                                 [CCScaleTo actionWithDuration:0.05 scale:iDevSize(1)], nil]];
        [pToMenuBtn runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.4 scale:iDevSize(1.2)],
                               [CCScaleTo actionWithDuration:0.2 scale:iDevSize(0.9)],
                               [CCScaleTo actionWithDuration:0.1 scale:iDevSize(1.05)],
                               [CCScaleTo actionWithDuration:0.05 scale:iDevSize(1)], nil]];
    }
    
	
}

-(void) drawLabels {
	CCLabelFX* pStageLbl = [CCLabelFX labelWithString:[NSString stringWithFormat:@"STA GE%d CLEA R", m_nlevel + 1] fontName:g_strFontName1 fontSize:23
										 shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pStageLbl];
	pStageLbl.position = ccpAdd(m_ptBackground, ccp(0, 30));
	pStageLbl.shadowColor = ccc4(255, 255, 255, 255);
	pStageLbl.color = ccRED;
	
	
	ccColor3B lblColor = ccc3(255, 255, 255);
	ccColor3B lblColor1 = ccc3(255, 255, 255);
	float lblFontSize = 17;
	
	CCLabelFX* pTimeBonusLbl = [CCLabelFX labelWithString:@"Bonus Point" fontName:g_strFontName fontSize:lblFontSize
                                             shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pTimeBonusLbl];
	pTimeBonusLbl.position = ccpAdd(m_ptBackground, ccp(-40, -6));
	pTimeBonusLbl.shadowColor = ccc4(255, 0, 0, 0);
	pTimeBonusLbl.color = lblColor;
	
	CCLabelFX* pBonusLbl = [CCLabelFX labelWithString:@"High Score" fontName:g_strFontName fontSize:lblFontSize
                                         shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pBonusLbl];
	pBonusLbl.position = ccpAdd(m_ptBackground, ccp(-40, -32));
	pBonusLbl.shadowColor = ccc4(255, 0, 0, 0);
	pBonusLbl.color = lblColor;
	
	m_pTimeBonusLbl = [CCLabelFX labelWithString:nil fontName:g_strFontName fontSize:lblFontSize
                                    shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:m_pTimeBonusLbl];
	m_pTimeBonusLbl.position = ccpAdd(m_ptBackground, ccp(46, -6));
	m_pTimeBonusLbl.color = lblColor1;
	m_pTimeBonusLbl.shadowColor = ccc4(255, 0, 0, 0);
	m_pTimeBonusLbl.visible = false;
	
	m_pBonusLabel = [CCLabelFX labelWithString:nil fontName:g_strFontName fontSize:lblFontSize
                                  shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:m_pBonusLabel];
	m_pBonusLabel.position = ccpAdd(m_ptBackground, ccp(46, -32));
	m_pBonusLabel.color = lblColor1;
	m_pBonusLabel.shadowColor = ccc4(255, 0, 0, 0);
	m_pBonusLabel.visible = false;
}

-(NSString*) getTimeString:(double)fTime {
	int nMinute = (int)fTime / 60;
	NSString * str = [NSString stringWithFormat:@"%.2f", fTime];
	int nLen = [str length];
	str = [str substringFromIndex:nLen - 2];
	int nSecond = (int)fTime % 60;
	if (nSecond < 10) {
		return [NSString stringWithFormat:@"0%d:0%d:%@", nMinute, nSecond, str];
	}
	return [NSString stringWithFormat:@"0%d:%d:%@", nMinute, nSecond, str];
}

-(void) onContinue {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
	[m_pApp changeWindow:WND_GAME param1:m_nNextWorld param2:m_nNextLevel];
}

-(void)	onToMenu {
    [m_soundManager playEffect:soundBtnClick bForce:YES];
    
	[m_pBonusLabel setString:[NSString stringWithFormat:@"%d", [AppSettings getScore:m_nworld nlevel:m_nlevel]]];
	m_nState = stateEnd;
	
	//[[SoundManager sharedSoundManager] playEffect:soundClickButton bForce:YES];
	
	[m_pApp changeWindow:WND_LEVEL];
}

-(void)	onTimer {
    double cur_time = [NSDate timeIntervalSinceReferenceDate];
	switch (m_nState) {
		case stateStart:
		{
			if (cur_time - m_actionStartTime > 1.6f) {
				[m_pTimeBonusLbl setVisible:true];
                //[[SoundManager sharedSoundManager] playEffect:soundScore loop:false];
                //[self addEmitter:[m_pTimeLbl position]];
                m_nState = stateTimeComplete;
				m_actionStartTime = cur_time;
			}
		}
			break;
		case stateTimeAnimating:
		{
			if (cur_time - m_actionStartTime > 0.4) {
				m_nState = stateTimeComplete;
				
			}
		}
			break;
		case stateTimeComplete:
		{
            
		}
			break;
		case stateTBAnimating:
		{
			if (cur_time - m_actionStartTime > 0.4) {
				m_nState = stateTBComplete;
			}
		}
			break;
		case stateTBComplete:
		{
			[m_pBonusLabel setVisible:true];
			[m_pBonusLabel setString:[NSString stringWithFormat:@"%d", [AppSettings getScore:m_nworld nlevel:m_nlevel]]];
						
			//[[SoundManager sharedSoundManager] playEffect:soundScore bForce:YES];
			
			[self addEmitter:[m_pBonusLabel position]];
			m_nState = stateBonusAnimating;
			m_actionStartTime = cur_time;
            
            [self drawBtns];
		}
			break;
		case stateBonusAnimating:
		{
			if (cur_time - m_actionStartTime > 0.4) {
				m_nState = stateBonusComplete;
			}
		}
			break;
		case stateBonusComplete:
		{
			m_nState = stateEnd;
		}
			break;
		default:
			break;
	}
}

-(void) addEmitter:(CGPoint)ptPos {	
	CCParticleSystem* m_pEmitter = [[[CCParticleSystemQuad alloc] initWithTotalParticles:50] autorelease];
	
	m_pEmitter.duration = 0.5f;
	m_pEmitter.angle = 90;
	m_pEmitter.angleVar = 360;
	
	m_pEmitter.emitterMode = kCCParticleModeGravity;
	
	m_pEmitter.gravity = CGPointMake(0, 0);
	m_pEmitter.speed = 70;
	m_pEmitter.speedVar = 40;
	m_pEmitter.tangentialAccel = 0.0f;
	m_pEmitter.tangentialAccelVar = 0.0f;
	m_pEmitter.radialAccel = 0.0f;
	m_pEmitter.radialAccelVar = 0.0f;
    
	m_pEmitter.startSize = 10.0f;
	m_pEmitter.startSizeVar = 5.0f;
	m_pEmitter.endSize = kCCParticleStartSizeEqualToEndSize;
	m_pEmitter.endSizeVar = 10.0f;
	m_pEmitter.life = 0.3f;
	m_pEmitter.lifeVar = 0.1f;
	m_pEmitter.startColor = (ccColor4F){1.0f, 0.3f, 0.0f, 1};
	m_pEmitter.startColorVar =(ccColor4F){0.0f, 0.1f, 0.0f, 0.3};
	m_pEmitter.endColor = (ccColor4F){1.0f, 0.3f, 0.0f, 1};
	m_pEmitter.endColorVar =(ccColor4F){0.0f, 0.1f, 0.0f, 0.3};
	m_pEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
	m_pEmitter.emissionRate = m_pEmitter.totalParticles / m_pEmitter.duration;
	m_pEmitter.blendAdditive = YES;
	m_pEmitter.position = ptPos;
	[self addChild:m_pEmitter];
}

-(void) addBackEmitter {
	CCParticleSystem* m_pEmitter = [[[CCParticleSystemQuad alloc] initWithTotalParticles:300] autorelease];
	
	m_pEmitter.duration = kCCParticleDurationInfinity;
	m_pEmitter.angle = -90;
	m_pEmitter.angleVar = 5;
	
	m_pEmitter.emitterMode = kCCParticleModeGravity;
	
	m_pEmitter.gravity = CGPointMake(0, -10);
	m_pEmitter.speed = 65;
	m_pEmitter.speedVar = 15;
	m_pEmitter.tangentialAccel = 0.0f;
	m_pEmitter.tangentialAccelVar = 1.0f;
	m_pEmitter.radialAccel = 0.0f;
	m_pEmitter.radialAccelVar = 1.0f;
	
	m_pEmitter.startSpin = 200.0f;
	m_pEmitter.startSpinVar = 100.0f;
	m_pEmitter.endSpin = 200.0f;
	m_pEmitter.endSpinVar = 100.0f;
	
	m_pEmitter.startSize = 12.0f;
	m_pEmitter.startSizeVar = 5.0f;
	m_pEmitter.endSize = kCCParticleStartSizeEqualToEndSize;
	m_pEmitter.endSizeVar = 10.0f;
	m_pEmitter.life = 5.0f;
	m_pEmitter.lifeVar = 1.0f;
	m_pEmitter.startColor = (ccColor4F){1.0f, 1.0f, 0.0f, 0};
	m_pEmitter.startColorVar =(ccColor4F){0.0f, 0.0f, 0.0f, 0};
	m_pEmitter.endColor = (ccColor4F){1.0f, 1.0f, 0.0f, 0};
	m_pEmitter.endColorVar =(ccColor4F){1.0f, 1.0f, 0.0f, 0};
	m_pEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars2.png"];
	m_pEmitter.emissionRate = 15;
	m_pEmitter.blendAdditive = NO;
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	m_pEmitter.position = ccpAdd(m_ptBackground, ccp(0, size.height * 0.6));
	m_pEmitter.posVar = CGPointMake(size.width / 2, 0);
	[self addChild:m_pEmitter];
}

-(void) updateQuads:(ccTime)dt
{
	/*index = (index + 1) % 4;
     CGRect rect = CGRectMake(index*32, 0,32,32);
     
     CCParticleSystemQuad *system = (CCParticleSystemQuad*) emitter;
     [system setTexture:[emitter texture] withRect:rect];*/
}

-(void) timeLabelAnimation {
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void) dealloc {
    [self unschedule:@selector(onTimer)];
    [self unschedule:@selector(BonusAnimate:)];
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}
@end
