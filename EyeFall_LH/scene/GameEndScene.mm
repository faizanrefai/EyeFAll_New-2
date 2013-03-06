#import "GameScene.h"
#import "GameEndScene.h"
#import "global.h"
#import "SoundManager.h"
#import "CCZoomButton.h"
#import "ScaleMenu.h"
#import "TitleScene.h"
#import "AppSettings.h"

#define PARTICLE_INTERVAL		2.0f

static const CGPoint ptParticle = CGPointMake(20, 568);
#define WIDTH		280
#define HEIGHT		100

enum  {
	kTagSuccessParticle = 3000,
};

@implementation GameEndScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameEndScene *layer = [GameEndScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)   initWithParameters:(int)world level:(int)level remainEyes:(int)remainEyes {
    if((self = [super init])){
        m_nworld = world;
        m_nlevel = level;
        m_nRemainEyes = remainEyes;
        
        int nScore = [AppSettings getScore:m_nworld nlevel:m_nlevel];
        nScore += m_nRemainEyes * 1000;
        [AppSettings setScore:m_nworld nlevel:m_nlevel nScore:nScore];
        
		self.isTouchEnabled = true;
		
		m_nBonus = 0;
				
		[self drawImages];
		[self drawLabels];
		[self drawBtns];
		[self addBackEmitter];
		
		[self scheduleUpdate];
	
		m_pApp = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
		[self schedule:@selector(onTimer:) interval:0.1];
	}
	return self;
}

-(void) update:(ccTime)delta {
	
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
	CCMenuItemImage * pToMenuBtn = [CCMenuItemImage itemFromNormalImage:@"back_level_0.png"
														  selectedImage:@"back_level_0.png"
																 target:self selector:@selector(onToMenu)];
	pToMenuBtn.position = ccpAdd(m_ptBackground, ccp(0, -60));
	
	ScaleMenu * Menu = [ScaleMenu menuWithItems:pToMenuBtn, nil];
	Menu.position = CGPointZero;
	[self addChild:Menu z:11];
}

-(void) drawLabels {
	CCLabelFX* pStageLbl = [CCLabelFX labelWithString:[NSString stringWithFormat:@"High Score %d", [AppSettings getScore:m_nworld nlevel:m_nlevel]] fontName:g_strFontName fontSize:iDevSize(22)
										 shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pStageLbl z:11];
	pStageLbl.position = ccpAdd(m_ptBackground, ccp(0, 20));
	pStageLbl.shadowColor = ccc4(255, 255, 255, 255);
	pStageLbl.color = ccRED;
	
	
	ccColor3B lblColor = ccc3(255, 255, 255);
	
	CCLabelFX* pBonusLbl = [CCLabelFX labelWithString:@"World4 is coming soon" fontName:g_strFontName fontSize:iDevSize(19)
										shadowOffset:CGSizeMake(1.5, -1.5) shadowBlur:0.5f];
	[self addChild:pBonusLbl z:11];
	pBonusLbl.position = ccpAdd(m_ptBackground, ccp(0, -15));
	pBonusLbl.shadowColor = ccc4(0, 255, 0, 255);
	pBonusLbl.color = lblColor;
}

-(void) onNewGame {
	
	GameScene * pParent = (GameScene *)[self parent];
	if (pParent) {
		
    }
}

-(void)	onToMenu {
	[[SoundManager sharedSoundManager] playEffect:soundBtnClick bForce:YES];
	
#ifdef USE_LOADING_SCENE
    [m_pApp changeWindow:WND_TITLE];
#else
    CCScene * scene = [TitleScene node];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
    [[CCDirector sharedDirector] replaceScene: ts];
#endif  //USE_LOADING_SCENE
}

-(void)	onTimer:(ccTime)dt {
    m_fParticle += dt;
	if ( m_fParticle > PARTICLE_INTERVAL) {
		m_fParticle = 0;
		[self addEmitter];
	}
}

-(void) addEmitter {	
	CCNode * node = [self getChildByTag:kTagSuccessParticle];
	if (node) {
		[node removeFromParentAndCleanup:YES];
	}
	
	CGPoint ptPos = ccpAdd(ptParticle, ccp(rand() % WIDTH, rand() % HEIGHT));
	
	CCParticleSystem* m_pEmitter = [[[CCParticleExplosion alloc] initWithTotalParticles:150] autorelease];
	
	//m_pEmitter.duration = 1.5f;
	
	m_pEmitter.startSize = 10.0f;
	m_pEmitter.startSizeVar = 5.0f;
	m_pEmitter.endSize = kCCParticleStartSizeEqualToEndSize;
	m_pEmitter.endSizeVar = 10.0f;
	m_pEmitter.life = 1.0f;
	m_pEmitter.lifeVar = 0.3f;
	m_pEmitter.startColor = (ccColor4F){1.0f, 0.4f, 0.0f, 0};
	m_pEmitter.startColorVar =(ccColor4F){0.3f, 0.3f, 0.1f, 0};
	m_pEmitter.endColor = (ccColor4F){1.0f, 0.5f, 0.0f, 0};
	m_pEmitter.endColorVar =(ccColor4F){0.3f, 0.3f, 0.1f, 0};
	m_pEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
	m_pEmitter.emissionRate = m_pEmitter.totalParticles / m_pEmitter.duration;
	m_pEmitter.blendAdditive = NO;
	m_pEmitter.position = ptPos;
	[self addChild:m_pEmitter z:0 tag:kTagSuccessParticle];
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
	
	m_pEmitter.startSize = 10.0f;
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
	m_pEmitter.emissionRate = 20;
	m_pEmitter.blendAdditive = NO;
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	m_pEmitter.position = ccpAdd(m_ptBackground, ccp(0, size.height * 0.6));
	m_pEmitter.posVar = CGPointMake(size.width / 2, 0);
	[self addChild:m_pEmitter];
}

-(void) timeLabelAnimation {
	[m_pTimeLbl setVisible:true];
	
	
}

-(void) dealloc {
    [self unschedule:@selector(onTimer:)];
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

@end
