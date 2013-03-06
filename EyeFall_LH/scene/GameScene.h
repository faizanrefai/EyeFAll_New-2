//
//  GameScene.h
//  EyeFall_box2d
//
//  Created by YunCholHo on 1/18/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LevelHelperLoader.h"
#import "LevelHelper.h"
#import "AppDelegate.h"
#import "MyListener.h"
#import "SpriteCloud.h"
#import "Eye.h"
#import "CCLabelFX.h"
#import "PopupMenuScene.h"
#import "SoundManager.h"
#import "ScaleLayer.h"

@class GrowButton;
// HelloWorld Layer
@interface GameScene : ScaleLayer
{
	b2World*            world;
	GLESDebugDraw *     m_debugDraw;
    
	LevelHelperLoader*  m_level;
    
    b2MouseJoint*       mouseJoint;
    
    MyListener*         m_pContactListener;
    
    AppDelegate*        m_appDelegate;
    SoundManager*       m_soundManager;
    
    SpriteCloud*        m_sprCloud[3];
    
    Eye*                m_pEye;
    
    int                 m_nScore;
    int                 m_nworld;
    int                 m_nlevel;
    int                 m_nScoreLblIndex;
    
    int                 m_nShootCount;
    int                 m_nEnemyCount;
    int                 m_nEyeCount;
    
    bool                m_bTouch;
    CGPoint             m_EyePosition;
    CGPoint             m_FixPosition;
    CGPoint             m_DragPosition;
    CGPoint             m_EyesPosition;
    CGPoint             m_ptClickPos;
    int                 m_GameState;

    b2Body*             m_pBody;
    
    CCLabelFX*          m_pScoreLabel;
    CCLabelFX*          m_pLivesLabel;
    CCLabelFX*          m_pTimeLabel;
    CCLabelFX*          m_pPauseLabel;
    
    CCSprite*           m_sprEye;
    
    float               m_aniEyeTime;
    
    NSTimeInterval      m_fGameTime;
    NSTimeInterval      m_fRemainTime;
    
    PopupMenuScene*     m_pPopMenu;
    
    GrowButton *        m_pMenuBtn;
    
    bool                m_bPaused;
    CCSprite*           m_pSprPause;
    CCMenuItemImage *menuResumeItem, *menuGridItem, *menuRestartItem, *menuMusicItem, *menuSoundItem, *menuPauseItem;
    CCMenu *menuResume, *menuPause;
    CCMenu *menuRestart_Grid;
    CCMenu *menuMusic_Sound;
    bool                m_bPopUpMenuAnimating;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene:(int)nworld level:(int)nlevel;
-(id) initWithParameters:(int)nworld level:(int)nlevel;
-(void) initVariables;
-(void) loadLevel;
-(void) initWorld;
-(void) drawLabels;
-(void) initImages;

-(void) createBtns;
-(void) createSnowParticle;
-(void) createEye;

-(void) onPause:(bool)bPaused;

- (void) createListener;
- (void) onTime:(ccTime) dt;

- (bool) checkGameSussess;
- (bool) checkGameFail;

- (void) SuccessProcess;
- (void) FailProcess;

- (void) setScore;
- (void) setLives;

-(void) MoveEye:(CGPoint)ptFixed ptEnd:(CGPoint)ptEnd;

-(void) scoreLabelAnimation:(int)nScore ptPos:(CGPoint)ptPos;

-(void) ResultLayerAnimation:(CCLayer*) layer;

-(void) PopupMenuAnimation:(bool)appear;
-(void) PopupMenuDisappeared;

-(void) worldLabelAnimation:(CCLabelFX*) pLabel;

-(void) EyeReadyAniEnd;
@end
