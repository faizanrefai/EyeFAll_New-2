//
//  SpriteCloud.h
//  EyeFall_LH
//
//  Created by YunCholHo on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface SpriteCloud : CCSprite {
    float       m_fVelocity;
    bool        m_bFromleft;
    float       m_fScale;
    CGRect      m_rtSky;
    CGPoint     m_ptPos;
}
- (id) initSpriteCloud;
- (void) setSkyRect:(CGRect)rtSky;
- (void) update:(ccTime)dt;

@end
