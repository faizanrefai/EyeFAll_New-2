//
//  Ball.h
//  PopIdol
//
//  Created by YunCholHo on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCParticleSystem.h"
#import "SoundManager.h"
@class LHSprite;

@interface Eye : NSObject {
	b2Body*		m_pBody;
	b2World*	m_pWorld;
	CCLayer*	m_pParent;
	LHSprite*	m_sprite;
    CCSprite*	m_sprOptic;
    
    CGPoint     m_ptFixed;
	
	int		m_nOpacity;
	
	float	m_fScale;
	float	m_weight;
    
    CCParticleSystem*  m_pEmitter;
    
    bool       m_bAnimationg;
    
    SoundManager*   m_soundManager;
}

@property(readwrite) b2Body* body;

- (id) initWithWorld:(b2World*) world pos:(CGPoint)pos Parent:(CCLayer*) pParent;
- (void) move;

- (float) scale;
- (float) weight;

- (CGPoint) getPosition;
- (CGPoint) getSprPosition;
- (CGFloat) getRotation;
- (void) applyForce:(float)x y:(float)y;
- (void) draw;
- (b2Body*) getBody;
- (LHSprite*) getUserData;
- (LHSprite*) getSprite;
- (void) setEyeTag:(int)nTag;
- (int) getEyeTag;
- (void) setPosition:(CGPoint)ptPos;
- (void) createObject:(CGPoint)p;

- (void) createParticle:(CGPoint) pt;

- (void) OpticAnimation:(ccTime) dt;
- (void) OpticAnimationEnd:(ccTime) dt;

- (void) drawLine:(CGPoint)ptPos;
@end
