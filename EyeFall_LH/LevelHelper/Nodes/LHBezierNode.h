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
@class LHPathNode;
@interface LHBezierNode : CCNode
{
	bool isClosed;
	bool isTile;
	bool isVisible;
	bool isLine;
	bool isPath;
	NSString* uniqueName;
	b2Body* body; //can be 0
	NSMutableArray* pathPoints;
	NSMutableSet* pathNodes;
	
	
	/////////for the tile feature
	CCTexture2D *texture;
	CGRect color;
	CGRect lineColor;
	float lineWidth;
	CGSize winSize;
	NSMutableArray* trianglesHolder;
	NSMutableArray* linesHolder;
	CGSize imageSize;
}
@property bool isClosed;
@property bool isTile;
@property bool isVisible;
@property bool isLine;

-(id) initWithDictionary:(NSDictionary*)properties 
			  cocosLayer:(CCLayer*)ccLayer
			 physicWorld:(b2World*)world;

+(id) nodeWithDictionary:(NSDictionary*)properties 
			  cocosLayer:(CCLayer*)ccLayer
			 physicWorld:(b2World*)world;

-(LHPathNode*)addSpriteOnPath:(LHSprite*)spr
                        speed:(float)pathSpeed 
              startAtEndPoint:(bool)startAtEndPoint
                     isCyclic:(bool)isCyclic
            restartAtOtherEnd:(bool)restartOtherEnd
              axisOrientation:(int)axis;

-(void) draw;
@end	
