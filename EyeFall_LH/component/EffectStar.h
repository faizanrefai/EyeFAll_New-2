//
//  EffectStar.h
//  ParkingMania
//
//  Created by YunCholHo on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum  {
	cBlue,
	cYellow,
};

@interface EffectStar : CCNode {

	float m_fScale;
	float m_fInc;
	float m_fFirstInc;
	
	int m_nColor;
	int m_nDistance;
    int m_nDistanceY;
}

-(void) setColor: (int) nColor;
@end
