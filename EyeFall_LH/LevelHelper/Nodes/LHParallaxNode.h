//  This file was generated by LevelHelper
//  http://www.levelhelper.org
//
//  LevelHelperLoader.h
//  Created by Bogdan Vladu
//  Copyright 2011 Bogdan Vladu. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  This notice may not be removed or altered from any source distribution.
//  By "software" the author refers to this code file and not the application 
//  that was used to generate this file.
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#include "Box2D.h"

@class LHSprite;
@interface LHParallaxNode : CCNode//CCParallaxNode 
{
	bool isContinuous;
	int direction;
	float speed;
	
	CGPoint lastPosition;
	
	CGSize winSize;
	
	
	int screenNumberOnTheRight;
	int screenNumberOnTheLeft;
	int screenNumberOnTheTop;
	int screenNumberOnTheBottom;
	
	NSMutableArray* sprites;
}
@property bool isContinuous;
@property int direction;
@property float speed;

-(id) initWithDictionary:(NSDictionary*)properties;
+(id) nodeWithDictionary:(NSDictionary*)properties;

-(void) addChild:(LHSprite*)sprite parallaxRatio:(CGPoint)ratio;

-(NSArray*)spritesInNode;
-(NSArray*)bodiesInNode;
@end	
