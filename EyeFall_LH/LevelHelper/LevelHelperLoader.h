//  This file is part of LevelHelper
//  http://www.levelhelper.org
//
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
//  You do not have permission to use this code or any part of it if you don't
//  own a license to LevelHelper application.
////////////////////////////////////////////////////////////////////////////////
//
//  Version history
//  ...............
//  v0.1 First version for LevelHelper 1.4
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "LHSprite.h"
#import "LHJoint.h"
#import "LHParallaxNode.h"
#import "LHBezierNode.h"
#import "LHBatch.h"

enum LevelHelper_TAG 
{ 
	DEFAULT_TAG = 0,
    STEEL_TAG = 4,
    WOOD_TAG,
    GROUND_TAG,
    ENEMY1_TAG,
    ENEMY2_TAG,
    ICE_TAG,
    FIRE_WOOD_TAG,
    ACID_TAG,
    GOLD_TAG,
    
    FIRE_EYE_TAG = 100,
    ACID_EYE_TAG,
    METAL_EYE_TAG,
    ICE_EYE_TAG,
};

enum LH_ACTIONS_TAGS
{
    LH_PATH_ACTION_TAG,
    LH_ANIM_ACTION_TAG
};

#if TARGET_OS_EMBEDDED || TARGET_OS_IPHONE || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64

#define LHRectFromString(str) CGRectFromString(str)
#define LHPointFromString(str) CGPointFromString(str)
#define LHPoint CGPoint
#define LHRect  CGRect
#define LHMakePoint(x, y) CGPointMake(x, y)

#else

#define LHRectFromString(str) NSRectToCGRect(NSRectFromString(str))
#define LHPointFromString(str) NSPointToCGPoint(NSPointFromString(str))
#define LHPoint NSPoint
#define LHRect NSRect
#define LHMakePoint(x, y) CGPointMake(x, y)

#endif
CGRect LHRectFromValue(NSValue* val);
NSValue* LHValueWithRect(CGRect rect);
CGPoint LHPointFromValue(NSValue* val);
NSValue* LHValueWithCGPoint(CGPoint pt);



@protocol LevelHelperLoaderCustomCCSprite
@optional

-(LHSprite*) spriteFromDictionary:(NSDictionary*)spriteProp;

-(LHSprite*) spriteWithBatchFromDictionary:(NSDictionary*)spriteProp 
								 batchNode:(LHBatch*)batch;

//this 3 methods should be overloaded together
//first one is for physic sprites 
-(void) setCustomAttributesForPhysics:(NSDictionary*)spriteProp 
								 body:(b2Body*)body
							   sprite:(LHSprite*)sprite;
//this second one is for the case where you dont use physics or you have sprites
//with "NO PHYSIC" as physic type
-(void) setCustomAttributesForNonPhysics:(NSDictionary*)spriteProp 
								  sprite:(LHSprite*)sprite;
//the third one is for bezier shapes that are not paths
-(void) setCustomAttributesForBezierBodies:(NSDictionary*)bezierProp 
                                      node:(CCNode*)sprite body:(b2Body*)body;


@end

@interface LevelHelperLoader : NSObject<LevelHelperLoaderCustomCCSprite> {
	
	NSArray* lhSprites;	//array of NSDictionary with keys GeneralProperties (NSDictionary) 
    //and PhysicProperties (NSDictionary)
	NSArray* lhJoints;	//array of NSDictionary
    NSArray* lhParallax;//array of NSDictionary 
    NSArray* lhBeziers; //array of NSDictionary
    NSArray* lhAnims;   //array of NSDictionary
	
    NSMutableDictionary* animationsInLevel; //key - uniqueAnimationName value - LHAnimation*
	NSMutableDictionary* spritesInLevel;	//key - uniqueSpriteName	value - LHSprite*
    NSMutableDictionary* jointsInLevel;     //key - uniqueJointName     value - LHJoint*
    NSMutableDictionary* parallaxesInLevel; //key - uniqueParallaxName  value - LHParallaxNode*
	NSMutableDictionary* beziersInLevel;    //key - uniqueBezierName    value - LHBezierNode*
	NSMutableDictionary* batchNodesInLevel;	//key - imageName			value - LHBatch*
    
    
	NSDictionary* wb; //world boundaries Info
    NSMutableDictionary* physicBoundariesInLevel; //keys//LHPhysicBoundarieTop
                                                        //LHPhysicBoundarieLeft
                                                        //LHPhysicBoundarieBottom
                                                        //LHPhysicBoundarieRight 
                                                    //value - LHSprite*    
	
	bool addSpritesToLayerWasUsed;
	bool addObjectsToWordWasUsed;
    
    CGPoint safeFrame;
    CGRect  gameWorldRect;
    CGPoint gravity;
	
    id  pathNotifierId;
    SEL pathNotifierSel;
    
    id      animNotifierId;
    SEL     animNotifierSel;
    bool    notifOnLoopForeverAnim;
    
	CCLayer* cocosLayer; //weak ptr
    b2World* box2dWorld; //weak ptr
}
//------------------------------------------------------------------------------
-(id) initWithContentOfFile:(NSString*)levelFile;
-(id) initWithContentOfFileFromInternet:(NSString*)webAddress;
-(id) initWithContentOfFile:(NSString*)levelFile 
			 levelSubfolder:(NSString*)levelFolder;
//------------------------------------------------------------------------------
//used by Scene Tester
-(id) initWithContentOfDictionary:(NSDictionary*)levelDictionary
					  imageFolder:(NSString*)imgFolder;
//------------------------------------------------------------------------------
//LOADING
-(void) addObjectsToWorld:(b2World*)world cocos2dLayer:(CCLayer*)cocosLayer;
-(void) addSpritesToLayer:(CCLayer*)cocosLayer; //NO PHYSICS
//------------------------------------------------------------------------------
//SPRITES
-(LHSprite*) spriteWithUniqueName:(NSString*)name; 
-(NSArray*)  spritesWithTag:(enum LevelHelper_TAG)tag; //returns array with LHSprite*
-(bool) removeSprite:(LHSprite*)ccsprite;
-(bool) removeSpritesWithTag:(enum LevelHelper_TAG)tag;
-(bool) removeAllSprites;
/*More methods in LHSpitesExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//CONVERSION
/*More methods in LHConversionExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//CREATION

//New sprite and associated body will be released automatically
//or you can use removeFromParentAndCleanup:YES, CCSprite method, to do it at a specific time
//you must set the desired position after creation

//sprites returned needs to be added in the layer by you
//new sprite unique name for the returned sprite will be
//[OLDNAME]_LH_NEW__SPRITE_XX and [OLDNAME]_LH_NEW_BODY_XX
-(LHSprite*) newSpriteWithUniqueName:(NSString *)name; //no physic body
-(LHSprite*) newPhysicalSpriteWithUniqueName:(NSString*)name;//with physic body

//sprites are added in the coresponding batch node automatically
//new sprite unique name for the returned sprite will be
//[OLDNAME]_LH_NEW_BATCH_SPRITE_XX and [OLDNAME]_LH_NEW_BATCH_BODY_XX
-(LHSprite*) newBatchSpriteWithUniqueName:(NSString*)name; //no physic body
-(LHSprite*) newPhysicalBatchSpriteWithUniqueName:(NSString*)name; //with physic body

/*More methods in LHCreationExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//JOINTS
-(LHJoint*) jointWithUniqueName:(NSString*)name;
-(NSArray*) jointsWithTag:(enum LevelHelper_TAG)tag; //returns array with LHJoint*
-(void) removeJointsWithTag:(enum LevelHelper_TAG)tag;
-(bool) removeJoint:(LHJoint*)joint;
-(bool) removeAllJoints;
/*More methods in LHJointsExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//PARALLAX
-(LHParallaxNode*) paralaxNodeWithUniqueName:(NSString*)uniqueName;
/*More methods in LHParallaxExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//BEZIER
-(LHBezierNode*) bezierNodeWithUniqueName:(NSString*)name;
-(void)          removeAllBezierNodes;
//------------------------------------------------------------------------------
//GRAVITY
-(bool) isGravityZero;
-(void) createGravity:(b2World*)world;
//------------------------------------------------------------------------------
//PHYSIC BOUNDARIES
-(void) createPhysicBoundaries:(b2World*)_world;
-(CGRect) physicBoundariesRect;
-(bool) hasPhysicBoundaries;

-(b2Body*) leftPhysicBoundary;
-(b2Body*) rightPhysicBoundary;
-(b2Body*) topPhysicBoundary;
-(b2Body*) bottomPhysicBoundary;
-(void) removePhysicBoundaries;
//------------------------------------------------------------------------------
//LEVEL INFO
-(CGPoint) gameScreenSize; //the device size set in loaded level
-(CGRect) gameWorldSize; //the size of the game world
//------------------------------------------------------------------------------
//BATCH
-(unsigned int) numberOfBatchNodesUsed;
/*More methods in LHBatchExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//ANIMATION
-(void) startAnimationWithUniqueName:(NSString *)animName 
                            onSprite:(LHSprite*)ccsprite;

-(void) stopAnimationOnSprite:(LHSprite*)ccsprite;

//this will not start the animation - it will just prepare it
-(void) prepareAnimationWithUniqueName:(NSString*)animName 
                              onSprite:(LHSprite*)sprite;


//needs to be called before addObjectsToWorld or addSpritesToLayer
//signature for registered method should be like this: -(void) spriteAnimHasEnded:(CCSprite*)spr animationName:(NSString*)animName
//registration is done like this: [loader registerNotifierOnAnimationEnds:self selector:@selector(spriteAnimHasEnded:animationName:)];
//this will trigger for all type of animations even for the ones controlled by you will next/prevFrameFor...
-(void) registerNotifierOnAllAnimationEnds:(id)obj selector:(SEL)sel;
/*
 by default the notification on animation end works only on non-"loop forever" animations
 if you want to receive notifications on "loop forever" animations enable this behaviour
 before addObjectsToWorld by calling the following function
 */
-(void) enableNotifOnLoopForeverAnimations;

/*More methods in LHAnimationsExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//PATH
-(void) moveSprite:(LHSprite *)ccsprite onPathWithUniqueName:(NSString*)uniqueName 
			 speed:(float)pathSpeed 
   startAtEndPoint:(bool)startAtEndPoint
          isCyclic:(bool)isCyclic
 restartAtOtherEnd:(bool)restartOtherEnd
   axisOrientation:(int)axis;

//DISCUSSION
//signature for registered method should be like this: -(void)spriteMoveOnPathEnded:(LHSprite*)spr pathUniqueName:(NSString*)str;
//registration is done like this: [loader registerNotifierOnPathEndPoints:self selector:@selector(spriteMoveOnPathEnded:pathUniqueName:)];
-(void) registerNotifierOnAllPathEndPoints:(id)obj selector:(SEL)sel;

/*More methods in LHPathExt.h - download from http://www.levelhelper.org*/
//------------------------------------------------------------------------------
//PHYSICS
+(void) setMeterRatio:(float)ratio; //default is 32.0f
+(float) meterRatio; //same as pointsToMeterRatio - provided for simplicity as static method

+(float) pixelsToMeterRatio;
+(float) pointsToMeterRatio;

+(b2Vec2) pixelToMeters:(CGPoint)point; //Cocos2d point to Box2d point
+(b2Vec2) pointsToMeters:(CGPoint)point; //Cocos2d point to Box2d point

+(CGPoint) metersToPoints:(b2Vec2)vec; //Box2d point to Cocos2d point
+(CGPoint) metersToPixels:(b2Vec2)vec; //Box2d point to Cocos2d pixels
//------------------------------------------------------------------------------
//needed when deriving this class
-(void) setSpriteProperties:(LHSprite*)ccsprite 
           spriteProperties:(NSDictionary*)spriteProp;
////////////////////////////////////////////////////////////////////////////////
@end
