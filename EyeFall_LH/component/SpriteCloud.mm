//
//  SpriteCloud.m
//  EyeFall_LH
//
//  Created by YunCholHo on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpriteCloud.h"
#import "global.h"

@implementation SpriteCloud

- (id) init {
    if (self = [super init]) {
        m_fVelocity = RandomFloat(5, 20) * SCALE_SCREEN_HEIGHT;
        m_fScale = RandomFloat(0.6, 1) * SCALE_SCREEN_HEIGHT;
        m_bFromleft = true;
        m_rtSky = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    return self;
}

- (id) initSpriteCloud {
    if (self = [super init]) {
        m_fVelocity = RandomFloat(10, 40);
        m_fScale = RandomFloat(0.6, 0.9);
        m_bFromleft = true;
        m_rtSky = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    return self;
}

- (void) setSkyRect:(CGRect)rtSky {
    m_rtSky = rtSky;
    m_ptPos = ccpAdd(m_rtSky.origin, ccp(RandomFloat(0, m_rtSky.size.width), RandomFloat(0, m_rtSky.size.height)));
    [self setPosition:m_ptPos];
    [self setScale:m_fScale];
}

- (void) update:(ccTime)dt {
    if (m_bFromleft) {
        m_ptPos.x +=  m_fVelocity * dt;
        if (m_ptPos.x >= SCREEN_WIDTH + iDevPixelX(60)) {
            m_ptPos.x = -iDevPixelX(60);
            m_ptPos.y = m_rtSky.origin.y + RandomFloat(0, m_rtSky.size.height);
            m_fVelocity = RandomFloat(5, 20) * SCALE_SCREEN_HEIGHT;
            m_fScale = RandomFloat(0.2, 0.5) * SCALE_SCREEN_HEIGHT;
            [self setScale:m_fScale];
        }
    }
    else {
        m_ptPos.x -= m_fVelocity * dt;
        if (m_ptPos.x < iDevPixelX(60)) {
            m_ptPos.x = SCREEN_WIDTH + iDevPixelX(60);
            m_ptPos.y = m_rtSky.origin.y + RandomFloat(0, m_rtSky.size.height);
            m_fVelocity = RandomFloat(5, 20) * SCALE_SCREEN_HEIGHT;
            m_fScale = RandomFloat(0.2, 0.5) * SCALE_SCREEN_HEIGHT;
            [self setScale:m_fScale];
        }
    }
    [self setPosition:m_ptPos];
}

@end
