//
//  Ball.m
//  PopIdol
//
//  Created by YunCholHo on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Eye.h"
#import "LHSprite.h"
#import "LevelHelperLoader.h"
#import "global.h"
#import "GameScene.h"

#define PTM_RATIO	32


@interface Eye()
- (void) createSprite:(CGPoint)p;
- (void) createObject:(CGPoint)p;
@end



@implementation Eye

@synthesize body = m_pBody;

- (id) initWithWorld:(b2World*)world pos:(CGPoint)pos Parent:(CCLayer *)pParent {
	if ((self = [super init])) {
		m_pWorld = world;
		m_pParent = pParent;
		
        m_soundManager = [SoundManager sharedSoundManager];
        
		m_nOpacity = 255;

		m_fScale = 1.0f;
        m_bAnimationg = false;
        
        m_ptFixed = ccp(iDevPixelX(187), iDevPixelY(367));
		
		[self createSprite:pos];
	}
	return self;
}

- (void) createSprite:(CGPoint)p {
	LHSprite *sprite;
    switch (g_SelectedEye) {
        case FIRE_EYE_TAG:
        {
            sprite = [[LHSprite spriteWithFile:@"eye_fire.png"] retain];
            m_sprOptic = [CCSprite spriteWithFile:@"optic_fire.png"];
        }
            break;
        case ACID_EYE_TAG:
        {
            sprite = [[LHSprite spriteWithFile:@"eye_acid.png"] retain];
            m_sprOptic = [CCSprite spriteWithFile:@"optic_acid.png"];
        }
            break;
        case METAL_EYE_TAG:
        {
            sprite = [[LHSprite spriteWithFile:@"eye_metal.png"] retain];
            m_sprOptic = [CCSprite spriteWithFile:@"optic_metal.png"];
        }
            break;
        case ICE_EYE_TAG:
        {
            sprite = [[LHSprite spriteWithFile:@"eye_ice.png"] retain];
            m_sprOptic = [CCSprite spriteWithFile:@"optic_ice.png"];
        }
            break;
        default:
            break;
    }
	[sprite setScale:m_fScale];
	sprite.position = ccp(iDevPixelX(269), iDevPixelY(407));
	[m_pParent addChild:sprite z:1];
	m_sprite = sprite;
    m_sprite.tag = g_SelectedEye;
    m_sprite.scale = 0.5;
    
    [m_pParent addChild:m_sprOptic];
    [m_sprOptic setScaleX:1.0f];
    [m_sprOptic setVisible:NO];
    
    
    [m_sprite runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.4 position:ccp(iDevPixelX(199), iDevPixelY(377))],
                                            [CCMoveTo actionWithDuration:0.15 position:ccp(iDevPixelX(187), iDevPixelY(377))],
                                            [CCSpawn actions:[CCScaleTo actionWithDuration:0.5 scale:1.2], [CCMoveBy actionWithDuration:0.5 position:ccp(0, iDevPixelY(10))], nil] ,
                                            [CCSpawn actions:[CCScaleTo actionWithDuration:0.15 scale:1.0], [CCMoveBy actionWithDuration:0.15 position:ccp(0, -iDevPixelY(3))], nil] ,
                                            [CCCallFuncN actionWithTarget:self selector:@selector(OpticAnimation:)],
                                            [CCMoveBy actionWithDuration:0.3 position:ccp(0, -iDevPixelY(45))],
                                            [CCMoveBy actionWithDuration:0.2 position:ccp(0, iDevPixelY(12))],
                                            [CCMoveBy actionWithDuration:0.15 position:ccp(0, -iDevPixelY(7))],
                                            [CCMoveBy actionWithDuration:0.1 position:ccp(0, iDevPixelY(3))],
                                            [CCCallFuncN actionWithTarget:self selector:@selector(OpticAnimationEnd:)],
                         nil]];
}

- (void) OpticAnimation:(ccTime) dt {
    m_bAnimationg = true;
    [m_sprOptic setVisible:YES];    
}

- (void) OpticAnimationEnd:(ccTime) dt {
    m_bAnimationg = false;
    [(GameScene*)m_pParent EyeReadyAniEnd];
}

- (void) createObject:(CGPoint)p {
	LHSprite *sprite = m_sprite;
	
	float	width = sprite.contentSize.width * m_fScale - iDevSize(8);
	CGFloat	fRadius = width / PTM_RATIO / 2.0f;
	
	// Define the dynamic body.
	
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x / PTM_RATIO, p.y / PTM_RATIO);
	bodyDef.userData = sprite;
	m_pBody = m_pWorld->CreateBody(&bodyDef);
    m_pBody->SetFixedRotation(true);
    
    [sprite setBody:m_pBody];
	// Define another box shape for our dynamic body.
	b2CircleShape shape;
	shape.m_radius = fRadius;
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = 0.4f;
	fixtureDef.friction = 1.0f;
	fixtureDef.restitution = 0.2f;
	m_pBody->CreateFixture(&fixtureDef);
    
    [self createParticle:p];
}

- (float) scale{
	return m_fScale;
}

- (float) weight{
	return m_weight;
}

- (void) applyForce:(float)x y:(float)y {
    [m_sprOptic setVisible:NO];
	b2Vec2 force;
	force.x = x;
	force.y = y;
	m_pBody->ApplyForce(force, m_pBody->GetPosition());
    
    [m_soundManager playEffect:soundShoot loop:NO];
}

- (void) move {
	CGPoint pt = [self getPosition];
	
	LHSprite* data = (LHSprite*)m_pBody->GetUserData();
	
	data.position = pt;
	data.rotation = -1 * CC_RADIANS_TO_DEGREES(m_pBody->GetAngle());
}

- (CGPoint) getPosition {
	return CGPointMake(m_pBody->GetPosition().x * PTM_RATIO, m_pBody->GetPosition().y * PTM_RATIO);
}

- (CGPoint) getSprPosition {
    return [m_sprite position];
}

- (CGFloat) getRotation {
	return	-1 * CC_RADIANS_TO_DEGREES(m_pBody->GetAngle());
}

- (b2Body*) getBody {
    return  m_pBody;
}

- (LHSprite*) getUserData {
    return (LHSprite*)m_pBody->GetUserData();
}

- (LHSprite*) getSprite {
    return m_sprite;
}

- (void) draw {
    if (m_pBody) {
        LHSprite* spr = (LHSprite*)m_pBody->GetUserData();
        [spr setPosition:[self getPosition]];  
        [m_pEmitter setPosition:[self getPosition]];
    }
    if (m_bAnimationg) {
        [self drawLine:[m_sprite position]];
    }
}

////////////////////////////////////////////////////////////////////////////////
-(void) createParticle:(CGPoint) pt
{
    CCNode* node = [m_pParent getChildByTag:_TAG_EYE_TAIL_PARTICLE];
    if (node) {
        [node removeFromParentAndCleanup:YES];
    }
	m_pEmitter = [[[CCParticleSystemQuad alloc] initWithTotalParticles:50] autorelease];
	
	m_pEmitter.duration = kCCParticleDurationInfinity;
	m_pEmitter.angle = 90;
	m_pEmitter.angleVar = 360;
	
	m_pEmitter.emitterMode = kCCParticleModeGravity;
	
	m_pEmitter.gravity = CGPointMake(0, 0);
	m_pEmitter.speed = 10 * SCALE_SCREEN_WIDTH;
	m_pEmitter.speedVar = 3 * SCALE_SCREEN_WIDTH;
	m_pEmitter.tangentialAccel = 0.0f;
	m_pEmitter.tangentialAccelVar = 0.0f;
	m_pEmitter.radialAccel = 0.0f;
	m_pEmitter.radialAccelVar = 0.0f;
	
	m_pEmitter.startSize = 10.0f * SCALE_SCREEN_WIDTH;
	m_pEmitter.startSizeVar = 2.5f * SCALE_SCREEN_WIDTH;
	m_pEmitter.endSize = 12.0f * SCALE_SCREEN_WIDTH;
	m_pEmitter.endSizeVar = 5.0f * SCALE_SCREEN_WIDTH;
	m_pEmitter.life = 0.5;
	m_pEmitter.lifeVar = 0.4f;
    
	
    int nTag = [m_sprite tag];
    switch (nTag) {
        case FIRE_EYE_TAG:
        {
            m_pEmitter.startColor = (ccColor4F){1.0f, 1.0f, 0.0f, 0};
            m_pEmitter.startColorVar =(ccColor4F){0.1f, 0.1f, 0.1f, 0};
            m_pEmitter.endColor = (ccColor4F){1.0f, 0.5f, 0.0f, 1};
            m_pEmitter.endColorVar =(ccColor4F){0.1f, 0.2f, 0.1f, 0};
        }
            break;
        case ACID_EYE_TAG:
        {
            m_pEmitter.startColor = (ccColor4F){0.0f, 1.0f, 0.0f, 0};
            m_pEmitter.startColorVar =(ccColor4F){0.1f, 0.1f, 0.1f, 0};
            m_pEmitter.endColor = (ccColor4F){0.0f, 0.5f, 0.0f, 1};
            m_pEmitter.endColorVar =(ccColor4F){0.1f, 0.2f, 0.1f, 0};
        }
            break;  
        case METAL_EYE_TAG:
        {
            m_pEmitter.startColor = (ccColor4F){0.2f, 0.2f, 0.2f, 0};
            m_pEmitter.startColorVar =(ccColor4F){0.1f, 0.1f, 0.1f, 0};
            m_pEmitter.endColor = (ccColor4F){0.2f, 0.2f, 0.2f, 1};
            m_pEmitter.endColorVar =(ccColor4F){0.1f, 0.1f, 0.1f, 0};
        }
            break;
        case ICE_EYE_TAG:
        {
            m_pEmitter.startColor = (ccColor4F){0.0f, 0.0f, 0.3f, 0};
            m_pEmitter.startColorVar =(ccColor4F){0.1f, 0.1f, 0.1f, 0};
            m_pEmitter.endColor = (ccColor4F){0.0f, 0.0f, 0.3f, 1};
            m_pEmitter.endColorVar =(ccColor4F){0.1f, 0.1f, 0.1f, 0};
        }
            break;
        default:
            break;
    }
	
	m_pEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
	m_pEmitter.emissionRate = m_pEmitter.totalParticles / m_pEmitter.duration;
	m_pEmitter.blendAdditive = NO;
	
	m_pEmitter.position = pt;
	
    [m_pParent addChild:m_pEmitter z:-1 tag:_TAG_EYE_TAIL_PARTICLE];
}

- (void) setEyeTag:(int)nTag {
    [m_sprite setTag:nTag];
    switch (nTag) {
        case FIRE_EYE_TAG:
        {
            CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addImage:@"eye_fire.png"];
            [m_sprite setTexture:tex];
            tex = [[CCTextureCache sharedTextureCache] addImage:@"optic_fire.png"];
            [m_sprOptic setTexture:tex];
            
        }
            break;
        case ACID_EYE_TAG:
        {
            CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addImage:@"eye_acid.png"];
            [m_sprite setTexture:tex];
            tex = [[CCTextureCache sharedTextureCache] addImage:@"optic_acid.png"];
            [m_sprOptic setTexture:tex];
        }
            break;
        case METAL_EYE_TAG:
        {
            CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addImage:@"eye_metal.png"];
            [m_sprite setTexture:tex];
            tex = [[CCTextureCache sharedTextureCache] addImage:@"optic_metal.png"];
            [m_sprOptic setTexture:tex];
        }
            break;
        case ICE_EYE_TAG:
        {
            CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addImage:@"eye_ice.png"];
            [m_sprite setTexture:tex];
            tex = [[CCTextureCache sharedTextureCache] addImage:@"optic_ice.png"];
            [m_sprOptic setTexture:tex];
        }
            break;
        default:
            break;
    }
}

- (int) getEyeTag {
    return [m_sprite tag];
}

- (void) drawLine:(CGPoint)ptPos {
    [m_sprOptic setPosition:ccpMidpoint(m_ptFixed, ptPos)];
    
    float fAngle = ccpToAngle(ccpSub(ptPos, m_ptFixed));
    fAngle = fAngle / M_PI * 180;
    if (fAngle <= 0) {
        fAngle = - 90 - fAngle;
    }
    else {
        fAngle = 270 - fAngle;
    }
    
    [m_sprOptic setRotation:fAngle];
    
    float distance = ccpDistance(ptPos, m_ptFixed);
    [m_sprOptic setScaleY:distance / 72];
}

- (void) setPosition:(CGPoint)ptPos {
    if (m_bAnimationg) {
        m_bAnimationg = false;
    }
    
    [m_sprite setPosition:ptPos];
    [self drawLine:ptPos];
}

- (void) dealloc {
    [m_pEmitter removeFromParentAndCleanup:YES];
    [m_sprOptic removeFromParentAndCleanup:YES];
    
    if (m_pBody) {
        LHSprite* data = (LHSprite*)m_pBody->GetUserData();
        [data stopAllActions];
        [data removeFromParentAndCleanup:YES];
        m_pWorld->DestroyBody(m_pBody);
    }
	else {
        [m_sprite stopAllActions];
        [m_sprite removeFromParentAndCleanup:YES];
    }
	
	[super dealloc];
}

@end
