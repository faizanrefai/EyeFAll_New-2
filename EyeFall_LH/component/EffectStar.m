//
//  EffectStar.m
//  ParkingMania
//
//  Created by YunCholHo on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EffectStar.h"
#import "ResourceManager.h"

@implementation EffectStar

-(id) init 
{
	if((self = [super init])) {
		
		m_fScale = 0;
		m_fInc = 0.02;
	}
	
	return self;
}

-(void) setColor: (int) nColor
{
	m_nColor = nColor;
	m_fInc = CCRANDOM_0_1() * 0.02;
	m_fFirstInc = m_fInc;
	m_nDistance = 0;
    m_nDistanceY = 0;
}

-(void) draw 
{
	CCSprite* star;
	
	switch(m_nColor) {
		case cBlue:
			star = [CCSprite spriteWithFile:@"blue_star.png"];
			break;
		case cYellow:
			star = [CCSprite spriteWithFile:@"yellow_star.png"];
			break;
	}

	
	m_fScale += m_fInc;
	
	if(m_fScale > 1) {
		m_fInc = -m_fFirstInc;
	}
	
	if(m_fScale < 0) {
		m_fInc = 0;
		m_fInc = m_fFirstInc;
		m_nDistance = CCRANDOM_0_1() * 80;
        m_nDistanceY = CCRANDOM_0_1() * 20;
	}
	
	star.position = ccp(star.position.x + m_nDistance * SCALE_SCREEN_WIDTH, star.position.y + m_nDistanceY * SCALE_SCREEN_HEIGHT);
		
	star.scale = m_fScale;	
	[star visit];
}

@end

