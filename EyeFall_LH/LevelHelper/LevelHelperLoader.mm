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

#import "LevelHelperLoader.h"

#import "LHSettings.h"

#import "LHSprite.h"
#import "LHAnimationNode.h"
#import "LHJoint.h"
#import "LHBatch.h"
#import "LHPathNode.h"
#import "LHBezierNode.h"



#if TARGET_OS_EMBEDDED || TARGET_OS_IPHONE || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64

CGPoint LHPointFromValue(NSValue* val)
{
    return [val CGPointValue];
}

NSValue* LHValueWithRect(CGRect rect)
{
    return [NSValue valueWithCGRect:rect];
}

NSValue* LHValueWithCGPoint(CGPoint pt)
{
    return [NSValue valueWithCGPoint:pt];
}

CGRect LHRectFromValue(NSValue* val)
{
    return [val CGRectValue];
}

#else

CGPoint LHPointFromValue(NSValue* val)
{
    NSPoint pt = [val pointValue];
    return CGPointMake(pt.x, pt.y);
}

NSValue* LHValueWithRect(CGRect rect)
{
    return [NSValue valueWithRect:NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
}

NSValue* LHValueWithPoint(NSPoint pt)
{
    return [NSValue valueWithPoint:pt];
}

NSValue* LHValueWithCGPoint(CGPoint pt)
{
    return [NSValue valueWithPoint:NSMakePoint(pt.x, pt.y)];
}

CGRect LHRectFromValue(NSValue* val)
{
    return NSRectToCGRect([val rectValue]);
}

#endif


////////////////////////////////////////////////////////////////////////////////
@interface LevelHelperLoader (Private)
//------------------------------------------------------------------------------
-(void) addBatchNodesToLayer:(CCLayer*)_cocosLayer;
-(void) releaseAllBatchNodes;
//------------------------------------------------------------------------------
-(void) createAllAnimationsInfo;
-(void) createAnimationFromDictionary:(NSDictionary*)spriteProp 
                           onCCSprite:(LHSprite*)ccsprite;
//------------------------------------------------------------------------------
-(void) createAllBeziers;
//------------------------------------------------------------------------------
-(void) createPathOnSprite:(LHSprite*)ccsprite 
            withProperties:(NSDictionary*)spriteProp;
//------------------------------------------------------------------------------
-(void) createSpritesWithPhysics;
-(void) setFixtureDefPropertiesFromDictionary:(NSDictionary*)spritePhysic 
									  fixture:(b2FixtureDef*)shapeDef;
-(b2Body*) b2BodyFromDictionary:(NSDictionary*)spritePhysic
			   spriteProperties:(NSDictionary*)spriteProp
						   data:(LHSprite*)ccsprite 
						  world:(b2World*)_world;
-(void) releaseAllSprites;
//------------------------------------------------------------------------------
-(void) createParallaxes;
-(LHParallaxNode*) parallaxNodeFromDictionary:(NSDictionary*)parallaxDict 
                                        layer:(CCLayer*)layer;
-(void) releaseAllParallaxes;
//------------------------------------------------------------------------------
-(void) createJoints;
-(LHJoint*) jointFromDictionary:(NSDictionary*)joint world:(b2World*)world;
-(void) releaseAllJoints;
//------------------------------------------------------------------------------
-(void) releasePhysicBoundaries;
//------------------------------------------------------------------------------
-(void)loadLevelHelperSceneFile:(NSString*)levelFile 
					inDirectory:(NSString*)subfolder
				   imgSubfolder:(NSString*)imgFolder;

-(void) loadLevelHelperSceneFromDictionary:(NSDictionary*)levelDictionary 
							  imgSubfolder:(NSString*)imgFolder;

-(void)loadLevelHelperSceneFileFromWebAddress:(NSString*)webaddress;

-(void)processLevelFileFromDictionary:(NSDictionary*)dictionary;

@end

@implementation LevelHelperLoader

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
-(void) initObjects
{
	batchNodesInLevel = [[NSMutableDictionary alloc] init];	
	spritesInLevel = [[NSMutableDictionary alloc] init];
    jointsInLevel = [[NSMutableDictionary alloc] init];
	beziersInLevel = [[NSMutableDictionary alloc] init];
    parallaxesInLevel = [[NSMutableDictionary alloc] init];
    animationsInLevel = [[NSMutableDictionary alloc] init];
    physicBoundariesInLevel = [[NSMutableDictionary alloc] init];
    
	addSpritesToLayerWasUsed = false;
	addObjectsToWordWasUsed = false;
    
	[[LHSettings sharedInstance] setLhPtmRatio:32.0f];
	
    notifOnLoopForeverAnim = false;
    
    
    
}
////////////////////////////////////////////////////////////////////////////////
-(id) initWithContentOfFile:(NSString*)levelFile
{
	NSAssert(nil!=levelFile, @"Invalid file given to LevelHelperLoader");
	
	if(!(self = [super init]))
	{
		NSLog(@"LevelHelperLoader ****ERROR**** : [super init] failer ***");
		return self;
	}
	
	[self initObjects];
	[self loadLevelHelperSceneFile:levelFile inDirectory:@"" imgSubfolder:@""];
	
	
	return self;
}
////////////////////////////////////////////////////////////////////////////////
-(id) initWithContentOfFileFromInternet:(NSString*)webAddress
{
	NSAssert(nil!=webAddress, @"Invalid file given to LevelHelperLoader");
	
	if(!(self = [super init]))
	{
		NSLog(@"LevelHelperLoader ****ERROR**** : [super init] failer ***");
		return self;
	}
	
	[self initObjects];
	[self loadLevelHelperSceneFileFromWebAddress:webAddress];
	
	return self;
}
////////////////////////////////////////////////////////////////////////////////
-(id) initWithContentOfFile:(NSString*)levelFile 
			 levelSubfolder:(NSString*)levelFolder
{
	NSAssert(nil!=levelFile, @"Invalid file given to LevelHelperLoader");
	
	if(!(self = [super init]))
	{
		NSLog(@"LevelHelperLoader ****ERROR**** : [super init] failer ***");
		return self;
	}
	
	[self initObjects];
	
	[self loadLevelHelperSceneFile:levelFile inDirectory:levelFolder imgSubfolder:@""];
	
	return self;	
}
////////////////////////////////////////////////////////////////////////////////
-(id) initWithContentOfDictionary:(NSDictionary*)levelDictionary
					  imageFolder:(NSString*)imgFolder;
{
	NSAssert(nil!=levelDictionary, @"Invalid dictionary given to LevelHelperLoader");
	
	if(!(self = [super init]))
	{
		NSLog(@"LevelHelperLoader ****ERROR**** : [super init] failer ***");
		return self;
	}
	
	[self initObjects];
	
	[self loadLevelHelperSceneFromDictionary:levelDictionary imgSubfolder:imgFolder];
	
	return self;	
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) addSpritesToLayer:(CCLayer*)_cocosLayer
{	
	NSAssert(addObjectsToWordWasUsed!=true, @"You can't use method addSpritesToLayer because you already used addObjectToWorld. Only one of the two can be used."); 
	NSAssert(addSpritesToLayerWasUsed!=true, @"You can't use method addSpritesToLayer again. You can only use it once. Create a new LevelHelperLoader object if you want to load the level again."); 
	
	addSpritesToLayerWasUsed = true;
	
	cocosLayer = _cocosLayer;
	
	[self addBatchNodesToLayer:cocosLayer];
	
    [self createAllAnimationsInfo];
    
    //we need to first create the path so we can assign the path to sprite on creation
    //    for(NSDictionary* bezierDict in lhBeziers)
    //    {
    //        //NSString* uniqueName = [bezierDict objectForKey:@"UniqueName"];
    //        if([[bezierDict objectForKey:@"IsPath"] boolValue])
    //        {
    //            [self createBezierPath:bezierDict];
    //        }
    //    }
    
    
	for(NSDictionary* dictionary in lhSprites)
	{
		NSDictionary* spriteProp = [dictionary objectForKey:@"GeneralProperties"];
		
		//find the coresponding batch node for this sprite
        LHBatch* bNode = [batchNodesInLevel objectForKey:[spriteProp objectForKey:@"Image"]];
		CCSpriteBatchNode *batch = [bNode spriteBatchNode];
		
		if(nil != batch)
		{
			LHSprite* ccsprite = [self spriteWithBatchFromDictionary:spriteProp batchNode:bNode];
			if(nil != ccsprite)
			{
				[batch addChild:ccsprite];
				[spritesInLevel setObject:ccsprite forKey:[spriteProp objectForKey:@"UniqueName"]];
                
                [self setCustomAttributesForNonPhysics:spriteProp
                                                sprite:ccsprite];
			}
            
            if(![[spriteProp objectForKey:@"PathName"] isEqualToString:@"None"])
            {
                //we have a path we need to follow
                [self createPathOnSprite:ccsprite
                          withProperties:spriteProp];
            }
            
			[self createAnimationFromDictionary:spriteProp onCCSprite:ccsprite];
		}
	}
    
    for(NSDictionary* parallaxDict in lhParallax)
    {
        //NSMutableDictionary* nodeInfo = [[[NSMutableDictionary alloc] init] autorelease];
        //       CCNode* node = [self parallaxNodeFromDictionary:parallaxDict layer:cocosLayer];
        
        //   if(nil != node)
        // {
        //[nodeInfo setObject:[parallaxDict objectForKey:@"ContinuousScrolling"] forKey:@"ContinuousScrolling"];
        //[//nodeInfo setObject:[parallaxDict objectForKey:@"Speed"] forKey:@"Speed"];
        //[nodeInfo setObject:[parallaxDict objectForKey:@"Direction"] forKey:@"Direction"];
        //[nodeInfo setObject:node forKey:@"Node"];
        //         [ccParallaxInScene setObject:node forKey:[parallaxDict objectForKey:@"UniqueName"]];
        //}
    }
}
////////////////////////////////////////////////////////////////////////////////
-(void) addObjectsToWorld:(b2World*)world 
			 cocos2dLayer:(CCLayer*)_cocosLayer
{
	
	NSAssert(addSpritesToLayerWasUsed!=true, @"You can't use method addObjectsToWorld because you already used addSpritesToLayer. Only one of the two can be used."); 
	NSAssert(addObjectsToWordWasUsed!=true, @"You can't use method addObjectsToWorld again. You can only use it once. Create a new LevelHelperLoader object if you want to load the level again."); 
	
	addObjectsToWordWasUsed = true;
	
	cocosLayer = _cocosLayer;
    box2dWorld = world;
	
    //order is important
	[self addBatchNodesToLayer:cocosLayer];
    [self createAllAnimationsInfo];    
    [self createAllBeziers];
    [self createSpritesWithPhysics];
    [self createParallaxes];
	[self createJoints];
	
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(CGPoint) gameScreenSize
{
    return safeFrame;
}

//------------------------------------------------------------------------------
-(CGRect) gameWorldSize
{
    CGPoint  wbConv = [[LHSettings sharedInstance] convertRatio];
	
    CGRect ws = gameWorldRect;
    
    ws.origin.x *= wbConv.x;
    ws.origin.y *= wbConv.y;
    ws.size.width *= wbConv.x;
    ws.size.height *= wbConv.y;
    
    return ws;
}
//------------------------------------------------------------------------------
-(unsigned int) numberOfBatchNodesUsed
{
	return (int)[batchNodesInLevel count] -1;
}



////////////////////////////////////////////////////////////////////////////////







-(void) dealloc
{
	//NSLog(@"LH Dealloc");
    
    [self releasePhysicBoundaries];
	[self removeAllBezierNodes];	
	[self releaseAllParallaxes];
    [self releaseAllJoints];	
    [self releaseAllSprites];
    [self releaseAllBatchNodes];
    
	[lhSprites release];
	[lhJoints release];
    [lhParallax release];
    [lhBeziers release];
    
    [super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
///////////////////////////PRIVATE METHODS//////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) addBatchNodesToLayer:(CCLayer*)_cocosLayer
{
	NSArray *keys = [batchNodesInLevel allKeys];
	int tag = 0;
	for(NSString* key in keys){
		LHBatch* info = [batchNodesInLevel objectForKey:key];
		[_cocosLayer addChild:[info spriteBatchNode] z:[info z] tag:tag];
		tag++;
	}
}
//------------------------------------------------------------------------------
-(void)releaseAllBatchNodes{
	[batchNodesInLevel removeAllObjects];
    [batchNodesInLevel release];
    batchNodesInLevel = nil;
}
////////////////////////////////////////////////////////////////////////////////
//ANIMATIONS
////////////////////////////////////////////////////////////////////////////////
-(void) createAllAnimationsInfo
{
    for(NSDictionary* animInfo in lhAnims)
    {
        NSString* uniqueAnimName = [animInfo objectForKey:@"UniqueName"];
        
        NSArray* framesInfo = [animInfo objectForKey:@"Frames"];
        
        bool loop           = [[animInfo objectForKey:@"LoopForever"] boolValue];
        float animSpeed     = [[animInfo objectForKey:@"Speed"] floatValue];
        int repetitions     = [[animInfo objectForKey:@"Repetitions"] intValue];
        bool startAtLaunch  = [[animInfo objectForKey:@"StartAtLaunch"] boolValue];
        
        NSString* image = [animInfo objectForKey:@"Image"];
        LHBatch* bNode = [batchNodesInLevel objectForKey:image];
		CCSpriteBatchNode *batch = [bNode spriteBatchNode];
        
        NSString* imgRetina = [[LHSettings sharedInstance] 
                               imagePath:image];
        
        NSMutableArray *ccframes = [NSMutableArray array];        
        for(NSDictionary* frm in framesInfo)
        {
            CGRect rect = LHRectFromString([frm objectForKey:@"FrameRect"]);
            if([[LHSettings sharedInstance] shouldScaleImageOnRetina:imgRetina]){
                rect.origin.x *=2.0f;
                rect.origin.y *=2.0f;
                rect.size.width *=2.0f;
                rect.size.height *=2.0f;
            }
            
            CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:[batch texture] 
                                                              rect:rect];
            [ccframes addObject:frame];      
        }
        
        LHAnimationNode* animNode = [LHAnimationNode animationNodeWithUniqueName:uniqueAnimName];
        [animNode setLoop:loop];
        [animNode setSpeed:animSpeed];
        [animNode setRepetitions:repetitions];
        [animNode setStartAtLaunch:startAtLaunch];
        [animNode setBatchNode:batch];
        [animNode setFrames:ccframes];
        
        [animationsInLevel setObject:animNode forKey:uniqueAnimName];
    }
}
//------------------------------------------------------------------------------
-(void) createAnimationFromDictionary:(NSDictionary*)spriteProp 
                           onCCSprite:(LHSprite*)ccsprite{
	
	
	NSString* animName = [spriteProp objectForKey:@"AnimName"];
	if(![animName isEqualToString:@""])
	{
        LHAnimationNode* animNode = [animationsInLevel objectForKey:animName];
        if(nil != animNode)
        {
            if([animNode startAtLaunch])
            {
                [animNode runAnimationOnSprite:ccsprite 
                               withNotifierObj:animNotifierId 
                                   notifierSel:animNotifierSel 
                                   notifOnLoop:notifOnLoopForeverAnim];
            }
            else
            {
                [self prepareAnimationWithUniqueName:animName onSprite:ccsprite];
            }
        }
	}
}
//------------------------------------------------------------------------------
-(void) startAnimationWithUniqueName:(NSString *)animName 
                            onSprite:(LHSprite*)ccsprite{    
    LHAnimationNode* animNode = [animationsInLevel objectForKey:animName];
    if(nil != animNode){
        [animNode runAnimationOnSprite:ccsprite 
                       withNotifierObj:animNotifierId 
                           notifierSel:animNotifierSel 
                           notifOnLoop:notifOnLoopForeverAnim];
    }
}
//------------------------------------------------------------------------------
-(void) stopAnimationOnSprite:(LHSprite*)ccsprite{
    if(nil != ccsprite){
        [ccsprite stopActionByTag:LH_ANIM_ACTION_TAG];
        [ccsprite setAnimation:nil];
    }    
}
//------------------------------------------------------------------------------
-(void) prepareAnimationWithUniqueName:(NSString*)animName 
                              onSprite:(LHSprite*)sprite{
    LHAnimationNode* animNode = [animationsInLevel objectForKey:animName];
    if(animNode == nil)
        return;
    [sprite setAnimation:animNode];
}
//------------------------------------------------------------------------------
-(void) registerNotifierOnAllAnimationEnds:(id)obj selector:(SEL)sel{
    animNotifierId = obj;
    animNotifierSel = sel;
}
//------------------------------------------------------------------------------
-(void) enableNotifOnLoopForeverAnimations{
    notifOnLoopForeverAnim = true;
}
////////////////////////////////////////////////////////////////////////////////
//GRAVITY
////////////////////////////////////////////////////////////////////////////////
-(bool) isGravityZero{
    if(gravity.x == 0 && gravity.y == 0)
        return true;
    return false;
}
//------------------------------------------------------------------------------
-(void) createGravity:(b2World*)world{
	if([self isGravityZero])
		NSLog(@"LevelHelper Warning: Gravity is not defined in the level. Are you sure you want to set a zero gravity?");
    world->SetGravity(b2Vec2(gravity.x, gravity.y));
}
////////////////////////////////////////////////////////////////////////////////
//PHYSIC BOUNDARIES
////////////////////////////////////////////////////////////////////////////////
-(b2Body*)physicBoundarieForKey:(NSString*)key{
    LHSprite* spr = [physicBoundariesInLevel objectForKey:key];
    if(nil == spr)
        return 0;
    return [spr body];
}
-(b2Body*) leftPhysicBoundary{
    return [self physicBoundarieForKey:@"LHPhysicBoundarieLeft"];
}
//------------------------------------------------------------------------------
-(b2Body*) rightPhysicBoundary{
	return [self physicBoundarieForKey:@"LHPhysicBoundarieRight"];
}
//------------------------------------------------------------------------------
-(b2Body*) topPhysicBoundary{
    return [self physicBoundarieForKey:@"LHPhysicBoundarieTop"];
}
//------------------------------------------------------------------------------
-(b2Body*) bottomPhysicBoundary{
    return [self physicBoundarieForKey:@"LHPhysicBoundarieBottom"];
}
//------------------------------------------------------------------------------
-(bool) hasPhysicBoundaries{
	if(wb == nil){
		return false;
	}
    CGRect rect = LHRectFromString([wb objectForKey:@"WBRect"]);    
    if(rect.size.width == 0 || rect.size.height == 0)
        return false;
	return true;
}
//------------------------------------------------------------------------------
-(CGRect) physicBoundariesRect{
    CGPoint  wbConv = [[LHSettings sharedInstance] convertRatio];
    CGRect rect = LHRectFromString([wb objectForKey:@"WBRect"]);    
    rect.origin.x = rect.origin.x*wbConv.x,
    rect.origin.y = rect.origin.y*wbConv.y;
    rect.size.width = rect.size.width*wbConv.x;
    rect.size.height= rect.size.height*wbConv.y;
    return rect;
}
//------------------------------------------------------------------------------
-(void) createPhysicBoundaries:(b2World*)_world{
	if(![self hasPhysicBoundaries]){
        NSLog(@"LevelHelper WARNING - Please create physic boundaries in LevelHelper in order to call method \"createPhysicBoundaries\"");
        return;
    }	
    
    CGPoint  wbConv = [[LHSettings sharedInstance] convertRatio];
    
    b2BodyDef bodyDef;		
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(0.0f, 0.0f);
    b2Body* wbBodyT = _world->CreateBody(&bodyDef);
	b2Body* wbBodyL = _world->CreateBody(&bodyDef);
	b2Body* wbBodyB = _world->CreateBody(&bodyDef);
	b2Body* wbBodyR = _world->CreateBody(&bodyDef);
	
	{
        LHSprite* spr = [[[LHSprite alloc] init] autorelease];
		[spr setTag:[[wb objectForKey:@"TagLeft"] intValue]]; 
		[spr setVisible:false];
		[spr setUniqueName:@"LHPhysicBoundarieLeft"];
        [spr setBody:wbBodyL];    
        wbBodyL->SetUserData(spr);
        [physicBoundariesInLevel setObject:spr forKey:@"LHPhysicBoundarieLeft"];
	}
	
	{
		LHSprite* spr = [[[LHSprite alloc] init] autorelease];
		[spr setTag:[[wb objectForKey:@"TagRight"] intValue]]; 
		[spr setVisible:false];
		[spr setUniqueName:@"LHPhysicBoundarieRight"];
        [spr setBody:wbBodyR];  
        wbBodyR->SetUserData(spr);
        [physicBoundariesInLevel setObject:spr forKey:@"LHPhysicBoundarieRight"];
	}
	
	{
		LHSprite* spr = [[[LHSprite alloc] init] autorelease];
		[spr setTag:[[wb objectForKey:@"TagTop"] intValue]]; 
		[spr setVisible:false];
		[spr setUniqueName:@"LHPhysicBoundarieTop"];
        [spr setBody:wbBodyT];  
        wbBodyT->SetUserData(spr);        
        [physicBoundariesInLevel setObject:spr forKey:@"LHPhysicBoundarieTop"];
	}
	
	{
		LHSprite* spr = [[[LHSprite alloc] init] autorelease];
		[spr setTag:[[wb objectForKey:@"TagBottom"] intValue]]; 
		[spr setVisible:false];
		[spr setUniqueName:@"LHPhysicBoundarieBottom"];
        [spr setBody:wbBodyB];  
        wbBodyB->SetUserData(spr);        
        [physicBoundariesInLevel setObject:spr forKey:@"LHPhysicBoundarieBottom"];
	}
	
	wbBodyT->SetSleepingAllowed([[wb objectForKey:@"CanSleep"] boolValue]);  
	wbBodyL->SetSleepingAllowed([[wb objectForKey:@"CanSleep"] boolValue]);  
	wbBodyB->SetSleepingAllowed([[wb objectForKey:@"CanSleep"] boolValue]);  
	wbBodyR->SetSleepingAllowed([[wb objectForKey:@"CanSleep"] boolValue]);  
	
	
    CGRect rect = LHRectFromString([wb objectForKey:@"WBRect"]);    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
//	if (CC_CONTENT_SCALE_FACTOR() == 2) {
//        winSize = CGSizeMake(640, 960);
//    }
    
    {//TOP
        b2EdgeShape shape;
		
        b2Vec2 pos1 = b2Vec2(rect.origin.x/[[LHSettings sharedInstance] lhPtmRatio]*wbConv.x,
							 (winSize.height - rect.origin.y*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        
        b2Vec2 pos2 = b2Vec2((rect.origin.x + rect.size.width)*wbConv.x/[[LHSettings sharedInstance] lhPtmRatio], 
							 (winSize.height - rect.origin.y*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);		
		shape.Set(pos1, pos2);
		
        b2FixtureDef fixture;
        [self setFixtureDefPropertiesFromDictionary:wb fixture:&fixture];
        fixture.shape = &shape;
        fixture.isSensor = false;
        wbBodyT->CreateFixture(&fixture);
    }
	
    {//LEFT
        b2EdgeShape shape;
		
		b2Vec2 pos1 = b2Vec2(rect.origin.x*wbConv.x/[[LHSettings sharedInstance] lhPtmRatio],
							 (winSize.height - rect.origin.y*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        
		b2Vec2 pos2 = b2Vec2((rect.origin.x*wbConv.x)/[[LHSettings sharedInstance] lhPtmRatio], 
							 (winSize.height - (rect.origin.y + rect.size.height)*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        shape.Set(pos1, pos2);
		
        b2FixtureDef fixture;
        [self setFixtureDefPropertiesFromDictionary:wb fixture:&fixture];
        fixture.shape = &shape;
        wbBodyL->CreateFixture(&fixture);
    }
	
    {//RIGHT
        b2EdgeShape shape;
        
        b2Vec2 pos1 = b2Vec2((rect.origin.x + rect.size.width)*wbConv.x/[[LHSettings sharedInstance] lhPtmRatio],
							 (winSize.height - rect.origin.y*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        
        b2Vec2 pos2 = b2Vec2((rect.origin.x+ rect.size.width)*wbConv.x/[[LHSettings sharedInstance] lhPtmRatio], 
							 (winSize.height - (rect.origin.y + rect.size.height)*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        shape.Set(pos1, pos2);
		
        b2FixtureDef fixture;
        [self setFixtureDefPropertiesFromDictionary:wb fixture:&fixture];
        fixture.shape = &shape;
        wbBodyR->CreateFixture(&fixture);
    }
	
    {//BOTTOM
        b2EdgeShape shape;
        
        b2Vec2 pos1 = b2Vec2(rect.origin.x*wbConv.x/[[LHSettings sharedInstance] lhPtmRatio],
							 (winSize.height - (rect.origin.y + rect.size.height)*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        
        b2Vec2 pos2 = b2Vec2((rect.origin.x+ rect.size.width)*wbConv.x/[[LHSettings sharedInstance] lhPtmRatio], 
							 (winSize.height - (rect.origin.y + rect.size.height)*wbConv.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        shape.Set(pos1, pos2);
		
        b2FixtureDef fixture;
        [self setFixtureDefPropertiesFromDictionary:wb fixture:&fixture];
        fixture.shape = &shape;
        fixture.isSensor = false;
        wbBodyB->CreateFixture(&fixture);
    }
}
//------------------------------------------------------------------------------
-(void) removePhysicBoundaries{    
    [physicBoundariesInLevel removeAllObjects];
}
//------------------------------------------------------------------------------
-(void) releasePhysicBoundaries{
    [self removePhysicBoundaries];
    [physicBoundariesInLevel release];
    physicBoundariesInLevel = nil;
}
////////////////////////////////////////////////////////////////////////////////
//PHYSICS
////////////////////////////////////////////////////////////////////////////////
+(void) setMeterRatio:(float)ratio{
	[[LHSettings sharedInstance] setLhPtmRatio:ratio];
}
//------------------------------------------------------------------------------
+(float) meterRatio{
	return [[LHSettings sharedInstance] lhPtmRatio];
}
//------------------------------------------------------------------------------
+(float) pixelsToMeterRatio{
    return [[LHSettings sharedInstance] lhPtmRatio]*[[LHSettings sharedInstance] convertRatio].x;
}
//------------------------------------------------------------------------------
+(float) pointsToMeterRatio{
    return [[LHSettings sharedInstance] lhPtmRatio];
}
//------------------------------------------------------------------------------
+(b2Vec2) pixelToMeters:(CGPoint)point{
    return b2Vec2(point.x / [LevelHelperLoader pixelsToMeterRatio], point.y / [self pixelsToMeterRatio]);
}
//------------------------------------------------------------------------------
+(b2Vec2) pointsToMeters:(CGPoint)point{
    return b2Vec2(point.x / [[LHSettings sharedInstance] lhPtmRatio], point.y / [[LHSettings sharedInstance] lhPtmRatio]);
}
//------------------------------------------------------------------------------
+(CGPoint) metersToPoints:(b2Vec2)vec{
    return CGPointMake(vec.x*[[LHSettings sharedInstance] lhPtmRatio], vec.y*[[LHSettings sharedInstance] lhPtmRatio]);
}
//------------------------------------------------------------------------------
+(CGPoint) metersToPixels:(b2Vec2)vec{
    return ccpMult(CGPointMake(vec.x, vec.y), [LevelHelperLoader pixelsToMeterRatio]);
}
////////////////////////////////////////////////////////////////////////////////
//BEZIERS
////////////////////////////////////////////////////////////////////////////////
-(void) createAllBeziers{
	for(NSDictionary* bezierDict in lhBeziers){
		LHBezierNode* node = [LHBezierNode nodeWithDictionary:bezierDict 
												   cocosLayer:cocosLayer
												  physicWorld:box2dWorld];
		
        NSString* uniqueName = [bezierDict objectForKey:@"UniqueName"];
		if(nil != node){
			[beziersInLevel setObject:node forKey:uniqueName];
			int z = [[bezierDict objectForKey:@"ZOrder"] intValue];
			[cocosLayer addChild:node z:z];
		}		
    }
}
//------------------------------------------------------------------------------
-(LHBezierNode*) bezierNodeWithUniqueName:(NSString*)name{
	return [beziersInLevel objectForKey:name];
}
//------------------------------------------------------------------------------
-(void) removeAllBezierNodes{
    NSArray* keys = [beziersInLevel allKeys];
    for(NSString* key in keys){
        LHBezierNode* node = [beziersInLevel objectForKey:key];
        if(nil != node){
            [node removeFromParentAndCleanup:YES];
        }
    }
    [beziersInLevel removeAllObjects];
    [beziersInLevel release];	
    beziersInLevel = nil;
}
////////////////////////////////////////////////////////////////////////////////
//PATH
////////////////////////////////////////////////////////////////////////////////
-(void) createPathOnSprite:(LHSprite*)ccsprite 
            withProperties:(NSDictionary*)spriteProp{
    if(nil == ccsprite || nil == spriteProp)
        return;
    
    NSString* uniqueName = [spriteProp objectForKey:@"PathName"];
    bool isCyclic = [[spriteProp objectForKey:@"PathIsCyclic"] boolValue];
    float pathSpeed = [[spriteProp objectForKey:@"PathSpeed"] floatValue];
    int startPoint = [[spriteProp objectForKey:@"PathStartPoint"] intValue]; //0 is first 1 is end
    bool pathOtherEnd = [[spriteProp objectForKey:@"PathOtherEnd"] boolValue]; //false means will restart where it finishes
    int axisOrientation = [[spriteProp objectForKey:@"PathOrientation"] intValue]; //false means will restart where it finishes
	
    [self moveSprite:ccsprite onPathWithUniqueName:uniqueName 
               speed:pathSpeed 
     startAtEndPoint:startPoint 
            isCyclic:isCyclic 
   restartAtOtherEnd:pathOtherEnd
	 axisOrientation:axisOrientation];
}
//------------------------------------------------------------------------------
-(void) moveSprite:(LHSprite *)ccsprite onPathWithUniqueName:(NSString*)uniqueName 
			 speed:(float)pathSpeed 
   startAtEndPoint:(bool)startAtEndPoint
          isCyclic:(bool)isCyclic
 restartAtOtherEnd:(bool)restartOtherEnd
   axisOrientation:(int)axis
{
    if(nil == ccsprite || uniqueName == nil)
        return;
	
	LHBezierNode* node = [self bezierNodeWithUniqueName:uniqueName];
	
	if(nil != node)
	{
		LHPathNode* pathNode = [node addSpriteOnPath:ccsprite
                                               speed:pathSpeed
                                     startAtEndPoint:startAtEndPoint
                                            isCyclic:isCyclic 
                                   restartAtOtherEnd:restartOtherEnd
                                     axisOrientation:axis];
        
        if(nil != pathNode)
        {
            [pathNode setPathNotifierObject:pathNotifierId];
            [pathNode setPathNotifierSelector:pathNotifierSel];
        }
	}
}
//------------------------------------------------------------------------------
-(void) registerNotifierOnAllPathEndPoints:(id)obj selector:(SEL)sel{
    pathNotifierId = obj;
    pathNotifierSel = sel;
}
////////////////////////////////////////////////////////////////////////////////
//SPRITES
////////////////////////////////////////////////////////////////////////////////
-(LHSprite*) spriteWithUniqueName:(NSString*)name{
    return [spritesInLevel objectForKey:name];	
}
//------------------------------------------------------------------------------
-(NSArray*)spritesWithTag:(enum LevelHelper_TAG)tag
{
	NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
	NSArray *keys = [spritesInLevel allKeys];
	for(NSString* key in keys){
		LHSprite* ccSprite = [spritesInLevel objectForKey:key];
		if(nil != ccSprite && [ccSprite tag] == (int)tag){
			[array addObject:ccSprite];
		}
	}
	return array;
}
//------------------------------------------------------------------------------
-(void)createSpritesWithPhysics{
    
    for(NSDictionary* dictionary in lhSprites)
	{
		NSDictionary* spriteProp = [dictionary objectForKey:@"GeneralProperties"];
		NSDictionary* physicProp = [dictionary objectForKey:@"PhysicProperties"];
		
        LHBatch* bNode = [batchNodesInLevel objectForKey:[spriteProp objectForKey:@"Image"]];
		CCSpriteBatchNode *batch = [bNode spriteBatchNode];
		
		if(nil != batch)
		{
            LHSprite* ccsprite = [self spriteWithBatchFromDictionary:spriteProp batchNode:bNode];
            [batch addChild:ccsprite z:[[spriteProp objectForKey:@"ZOrder"] intValue]];
            
            NSString* uniqueName = [spriteProp objectForKey:@"UniqueName"];
            if([[physicProp objectForKey:@"Type"] intValue] != 3) //3 means no physic
            {
                b2Body* body = [self b2BodyFromDictionary:physicProp
                                         spriteProperties:spriteProp
                                                     data:ccsprite 
                                                    world:box2dWorld];
                
                if(0 != body)
                    [ccsprite setBody:body];
                
                [spritesInLevel setObject:ccsprite forKey:uniqueName];			
            }
            else {
                [spritesInLevel setObject:ccsprite forKey:uniqueName];
                [self setCustomAttributesForNonPhysics:spriteProp
                                                sprite:ccsprite];
            }
            
            if(![[spriteProp objectForKey:@"IsInParallax"] boolValue] &&
               ![[spriteProp objectForKey:@"PathName"] isEqualToString:@"None"])
            {
                [self createPathOnSprite:ccsprite
                          withProperties:spriteProp];
            }
            
            [self createAnimationFromDictionary:spriteProp onCCSprite:ccsprite];
		}
	}
}
//------------------------------------------------------------------------------
-(void) setFixtureDefPropertiesFromDictionary:(NSDictionary*)spritePhysic 
									  fixture:(b2FixtureDef*)shapeDef
{
	shapeDef->density = [[spritePhysic objectForKey:@"Density"] floatValue];
	shapeDef->friction = [[spritePhysic objectForKey:@"Friction"] floatValue];
	shapeDef->restitution = [[spritePhysic objectForKey:@"Restitution"] floatValue];
	
	shapeDef->filter.categoryBits = [[spritePhysic objectForKey:@"Category"] intValue];
	shapeDef->filter.maskBits = [[spritePhysic objectForKey:@"Mask"] intValue];
	shapeDef->filter.groupIndex = [[spritePhysic objectForKey:@"Group"] intValue];
    
    shapeDef->isSensor = [[spritePhysic objectForKey:@"IsSensor"] boolValue];
}
//------------------------------------------------------------------------------
-(b2Body*) b2BodyFromDictionary:(NSDictionary*)spritePhysic
			   spriteProperties:(NSDictionary*)spriteProp
						   data:(LHSprite*)ccsprite 
						  world:(b2World*)_world
{
	b2BodyDef bodyDef;	
	
	int bodyType = [[spritePhysic objectForKey:@"Type"] intValue];
	if(bodyType == 3) //in case the user wants to create a body with a sprite that has type as "NO_PHYSIC"
		bodyType = 2;
	bodyDef.type = (b2BodyType)bodyType;
	
	CGPoint pos = [ccsprite position];	
	bodyDef.position.Set(pos.x/[[LHSettings sharedInstance] lhPtmRatio],pos.y/[[LHSettings sharedInstance] lhPtmRatio]);
    
	bodyDef.angle = CC_DEGREES_TO_RADIANS(-1*[[spriteProp objectForKey:@"Angle"] floatValue]);
    bodyDef.userData = ccsprite;
    
	b2Body* body = _world->CreateBody(&bodyDef);
    
	body->SetFixedRotation([[spritePhysic objectForKey:@"FixedRot"] boolValue]);
	
	CGPoint linearVelocity = LHPointFromString([spritePhysic objectForKey:@"LinearVelocity"]);
	
    float linearDamping = [[spritePhysic objectForKey:@"LinearDamping"] floatValue]; 
    float angularVelocity = [[spritePhysic objectForKey:@"AngularVelocity"] floatValue];
    float angularDamping = [[spritePhysic objectForKey:@"AngularDamping"] floatValue];     
    
    bool isBullet = [[spritePhysic objectForKey:@"IsBullet"] boolValue];
    bool canSleep = [[spritePhysic objectForKey:@"CanSleep"] boolValue];
	
	
	NSArray* fixtures = [spritePhysic objectForKey:@"ShapeFixtures"];
	CGPoint scale = LHPointFromString([spriteProp objectForKey:@"Scale"]); 
    
    CGPoint size = LHPointFromString([spriteProp objectForKey:@"Size"]);
    
    CGPoint border = LHPointFromString([spritePhysic objectForKey:@"ShapeBorder"]);
    
	CGPoint offset = LHPointFromString([spritePhysic objectForKey:@"ShapePositionOffset"]);
	
	float gravityScale = [[spritePhysic objectForKey:@"GravityScale"] floatValue];
	
    scale.x *= [[LHSettings sharedInstance] convertRatio].x;
    scale.y *= [[LHSettings sharedInstance] convertRatio].y;        
    
	if(scale.x == 0)
		scale.x = 0.01;
	if(scale.y == 0)
		scale.y = 0.01;
	
	if(fixtures == nil || [fixtures count] == 0 || [[fixtures objectAtIndex:0] count] == 0)
	{
		b2PolygonShape shape;
		b2FixtureDef fixture;
		b2CircleShape circle;
		[self setFixtureDefPropertiesFromDictionary:spritePhysic fixture:&fixture];
		
		if([[spritePhysic objectForKey:@"IsCircle"] boolValue])
		{
            if([[LHSettings sharedInstance] convertLevel])
            {
				//    NSLog(@"convert circle");
                //this is for the ipad scale on circle look weird if we dont do this
                float scaleSpr = [ccsprite scaleX];
                [ccsprite setScaleY:scaleSpr];
            }
            
			float circleScale = scale.x; //if we dont do this we dont have collision
			if(circleScale < 0)
				circleScale = -circleScale;
			
			float radius = (size.x*circleScale/2.0f - border.x/2.0f*circleScale)/[[LHSettings sharedInstance] lhPtmRatio];
			
			if(radius < 0)
				radius *= -1;
			circle.m_radius = radius; 
			
			circle.m_p.Set(offset.x/2.0f/[[LHSettings sharedInstance] lhPtmRatio], -offset.y/2.0f/[[LHSettings sharedInstance] lhPtmRatio]);
			
			fixture.shape = &circle;
            body->CreateFixture(&fixture);
		}
		else
		{
            //THIS WAS ADDED BECAUSE I DISCOVER A BUG IN BOX2d
            //that makes linearImpulse to not work the body is in contact with
            //a box object
            int vsize = 4;
			b2Vec2 *verts = new b2Vec2[vsize];
			b2PolygonShape shape;
			
            verts[0].x = ( (-1* size.x + border.x/2.0f)*scale.x/2.0f+offset.x/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
            verts[0].y = ( (-1* size.y + border.y/2.0f)*scale.y/2.0f-offset.y/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
			
            verts[1].x = ( (+ size.x - border.x/2.0f)*scale.x/2.0f+offset.x/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
            verts[1].y = ( (-1* size.y + border.y/2.0f)*scale.y/2.0f-offset.y/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
			
            verts[2].x = ( (+ size.x - border.x/2.0f)*scale.x/2.0f+offset.x/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
            verts[2].y = ( (+ size.y - border.y/2.0f)*scale.y/2.0f-offset.y/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
			
            verts[3].x = ( (-1* size.x + border.x/2.0f)*scale.x/2.0f+offset.x/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
            verts[3].y = ( (+ size.y - border.y/2.0f)*scale.y/2.0f-offset.y/2.0f)/[[LHSettings sharedInstance] lhPtmRatio];
			
			shape.Set(verts, vsize);		
            
			fixture.shape = &shape;
            body->CreateFixture(&fixture);
            delete verts;
		}
	}
	else
	{
		for(NSArray* curFixture in fixtures)
		{
			int size = (int)[curFixture count];
			b2Vec2 *verts = new b2Vec2[size];
			b2PolygonShape shape;
			int i = 0;
			for(NSString* pointStr in curFixture)
			{
				CGPoint point = LHPointFromString(pointStr);
				verts[i] = b2Vec2((point.x*(scale.x)+offset.x/2.0f)/[[LHSettings sharedInstance] lhPtmRatio], 
								  (point.y*(scale.y)-offset.y/2.0f)/[[LHSettings sharedInstance] lhPtmRatio]);
				++i;
			}
			shape.Set(verts, size);		
			b2FixtureDef fixture;
			[self setFixtureDefPropertiesFromDictionary:spritePhysic fixture:&fixture];
			fixture.shape = &shape;
			body->CreateFixture(&fixture);
			delete[] verts;
		}
	}
	
    [self setCustomAttributesForPhysics:spriteProp 
								   body:body
								 sprite:ccsprite];
	
	body->SetGravityScale(gravityScale);
	body->SetSleepingAllowed(canSleep);    
    body->SetBullet(isBullet);
    body->SetLinearVelocity(b2Vec2(linearVelocity.x, linearVelocity.y));
    body->SetAngularVelocity(angularVelocity);
    body->SetLinearDamping(linearDamping);
    body->SetAngularDamping(angularDamping);
	
	
	return body;
	
}
//------------------------------------------------------------------------------
-(void)releaseAllSprites{
    [self removeAllSprites];
	[spritesInLevel removeAllObjects];
    [spritesInLevel release];
    spritesInLevel = nil;
}
//------------------------------------------------------------------------------
-(bool) removeSprite:(LHSprite*)ccsprite{
	if(nil == ccsprite)
		return false;
    
    if([ccsprite respondsToSelector:@selector(uniqueName)]){
        [spritesInLevel removeObjectForKey:[ccsprite uniqueName]];
    }
    [ccsprite removeFromParentAndCleanup:YES];	
	return true;
}
//------------------------------------------------------------------------------
-(bool) removeSpritesWithTag:(enum LevelHelper_TAG)tag{
	NSArray *keys = [spritesInLevel allKeys];
    if(nil == keys)
        return false;
	for(NSString* key in keys){
        LHSprite* spr = [self spriteWithUniqueName:key];
        if(nil != spr){
            if(tag == [spr tag]){
                [self removeSprite:spr];
            }
        }
	}
	return true;	
}
//------------------------------------------------------------------------------
-(bool) removeAllSprites{	
	NSArray *keys = [spritesInLevel allKeys];
    if(keys == nil)
        return false;
	for(NSString* key in keys){
        if(key != nil){
            LHSprite* spr = [self spriteWithUniqueName:key];
            [self removeSprite:spr];
        }
	}
	return true;	
}
//------------------------------------------------------------------------------
-(LHSprite*) newSpriteWithUniqueName:(NSString *)name{
    for(NSDictionary* dictionary in lhSprites){
		NSDictionary* spriteProp = [dictionary objectForKey:@"GeneralProperties"];
		if([[spriteProp objectForKey:@"UniqueName"] isEqualToString:name]){            
            LHSprite* ccsprite =  [self spriteFromDictionary:spriteProp];
            NSString* uName = [NSString stringWithFormat:@"%@_LH_NEW_SPRITE_%d", 
                               name, [[LHSettings sharedInstance] newBodyId]];
            [ccsprite setUniqueName:uName];
            return ccsprite;
        }
    }
    return nil;
}
//------------------------------------------------------------------------------
-(LHSprite*) newPhysicalSpriteWithUniqueName:(NSString*)name{
    for(NSDictionary* dictionary in lhSprites){
		NSDictionary* spriteProp = [dictionary objectForKey:@"GeneralProperties"];
		if([[spriteProp objectForKey:@"UniqueName"] isEqualToString:name]){            
            NSDictionary* physicProp = [dictionary objectForKey:@"PhysicProperties"];
            LHSprite* ccsprite = [self spriteFromDictionary:spriteProp];

            b2Body* body =  [self b2BodyFromDictionary:physicProp
                                      spriteProperties:spriteProp
                                                  data:ccsprite 
                                                 world:box2dWorld];

            if(0 != body)
                [ccsprite setBody:body];

            NSString* uName = [NSString stringWithFormat:@"%@_LH_NEW_BODY_%d", 
                               name, [[LHSettings sharedInstance] newBodyId]];
            [ccsprite setUniqueName:uName];

            return ccsprite;
        }
    }
    return nil;
}
//------------------------------------------------------------------------------
-(LHSprite*) newBatchSpriteWithUniqueName:(NSString *)name{
	for(NSDictionary* dictionary in lhSprites)
    {
		NSDictionary* spriteProp = [dictionary objectForKey:@"GeneralProperties"];
		if([[spriteProp objectForKey:@"UniqueName"] isEqualToString:name]){            
            //find the coresponding batch node for this sprite
            LHBatch* bNode = [batchNodesInLevel objectForKey:[spriteProp objectForKey:@"Image"]];
            if(nil != bNode){
                CCSpriteBatchNode *batch = [bNode spriteBatchNode];
                if(nil != batch){
                    LHSprite* ccsprite = [self spriteWithBatchFromDictionary:spriteProp batchNode:bNode];
                    [batch addChild:ccsprite z:[[spriteProp objectForKey:@"ZOrder"] intValue]];
                    
                    NSString* uName = [NSString stringWithFormat:@"%@_LH_NEW_BATCH_SPRITE_%d", 
                                       name, [[LHSettings sharedInstance] newBodyId]];
                    [ccsprite setUniqueName:uName];
                    return ccsprite;
                }
            }
        }
    }
    return nil;
}
//------------------------------------------------------------------------------
-(LHSprite*) newPhysicalBatchSpriteWithUniqueName:(NSString *)name{
	for(NSDictionary* dictionary in lhSprites)
    {
		NSDictionary* spriteProp = [dictionary objectForKey:@"GeneralProperties"];
		if([[spriteProp objectForKey:@"UniqueName"] isEqualToString:name]){            
            //find the coresponding batch node for this sprite
            LHBatch* bNode = [batchNodesInLevel objectForKey:[spriteProp objectForKey:@"Image"]];
            if(nil != bNode){
                CCSpriteBatchNode *batch = [bNode spriteBatchNode];
                if(nil != batch){
                    LHSprite* ccsprite = [self spriteWithBatchFromDictionary:spriteProp batchNode:bNode];
                    [batch addChild:ccsprite z:[[spriteProp objectForKey:@"ZOrder"] intValue]];
                    
                    NSDictionary* physicProp = [dictionary objectForKey:@"PhysicProperties"];
                    b2Body* body =  [self b2BodyFromDictionary:physicProp
                                              spriteProperties:spriteProp
                                                          data:ccsprite 
                                                         world:box2dWorld];
                    
                    if(0 != body)
                        [ccsprite setBody:body];
                    
                    NSString* uName = [NSString stringWithFormat:@"%@_LH_NEW_BATCH_BODY_%d", 
                                       name, [[LHSettings sharedInstance] newBodyId]];
                    [ccsprite setUniqueName:uName];
                    return ccsprite;
                }
            }
        }
    }
    return nil;
}
//------------------------------------------------------------------------------
-(LHSprite*) spriteFromDictionary:(NSDictionary*)spriteProp{
    CGRect uv = LHRectFromString([spriteProp objectForKey:@"UV"]);
  
    NSString* img = [[LHSettings sharedInstance] 
                     imagePath:[spriteProp objectForKey:@"Image"]];
    
    if([[LHSettings sharedInstance] shouldScaleImageOnRetina:img])
    {
        uv.origin.x *=2.0f;
        uv.origin.y *=2.0f;
        uv.size.width *=2.0f;
        uv.size.height *=2.0f;
    }
	LHSprite *ccsprite = [LHSprite spriteWithFile:img
											 rect:uv];
	[self setSpriteProperties:ccsprite spriteProperties:spriteProp];
	return ccsprite;
}
//------------------------------------------------------------------------------
-(LHSprite*) spriteWithBatchFromDictionary:(NSDictionary*)spriteProp 
								 batchNode:(LHBatch*)lhBatch{
    CGRect uv = LHRectFromString([spriteProp objectForKey:@"UV"]);
    
    if(lhBatch == nil)
        return nil;
    
    CCSpriteBatchNode* batch = [lhBatch spriteBatchNode];
    
    if(batch == nil)
        return nil;
    
    NSString* img = [[LHSettings sharedInstance] 
                     imagePath:[lhBatch uniqueName]];
    
    if([[LHSettings sharedInstance] shouldScaleImageOnRetina:img])
    {
        uv.origin.x *=2.0f;
        uv.origin.y *=2.0f;
        uv.size.width *=2.0f;
        uv.size.height *=2.0f;
    }
    
 	LHSprite *ccsprite = [LHSprite spriteWithBatchNode:batch 
                                                  rect:uv];
	[self setSpriteProperties:ccsprite spriteProperties:spriteProp];
	return ccsprite;	
}
//------------------------------------------------------------------------------
-(void) setSpriteProperties:(LHSprite*)ccsprite
           spriteProperties:(NSDictionary*)spriteProp
{
	//convert position from LH to Cocos2d coordinates
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CGPoint position = LHPointFromString([spriteProp objectForKey:@"Position"]);
	
	position.x *= [[LHSettings sharedInstance] convertRatio].x;
	position.y *= [[LHSettings sharedInstance] convertRatio].y;
    
    position.y = winSize.height - position.y;
    
	[ccsprite setPosition:position];
	[ccsprite setRotation:[[spriteProp objectForKey:@"Angle"] floatValue]];
	[ccsprite setOpacity:255*[[spriteProp objectForKey:@"Opacity"] floatValue]*[[LHSettings sharedInstance] customAlpha]];
	CGRect color = LHRectFromString([spriteProp objectForKey:@"Color"]);
	[ccsprite setColor:ccc3(255*color.origin.x, 255*color.origin.y, 255*color.size.width)];
	CGPoint scale = LHPointFromString([spriteProp objectForKey:@"Scale"]);
	[ccsprite setVisible:[[spriteProp objectForKey:@"IsDrawable"] boolValue]];
    [ccsprite setTag:[[spriteProp objectForKey:@"Tag"] intValue]];
    
	scale.x *= [[LHSettings sharedInstance] convertRatio].x;
	scale.y *= [[LHSettings sharedInstance] convertRatio].y;
	
    
    NSString* img = [[LHSettings sharedInstance] 
                     imagePath:[spriteProp objectForKey:@"Image"]];
    
    if([[LHSettings sharedInstance] shouldScaleImageOnRetina:img])
    {
        scale.x /=2.0f;
        scale.y /=2.0f;
    }
    
    //this is to fix a noise issue on cocos2d.
    scale.x += 0.015f*scale.x;
    scale.y += 0.015f*scale.y;
   
	[ccsprite setScaleX:scale.x];
	[ccsprite setScaleY:scale.y];
	
    [ccsprite setUniqueName:[spriteProp objectForKey:@"UniqueName"]];
}
////////////////////////////////////////////////////////////////////////////////
//PARALLAX
////////////////////////////////////////////////////////////////////////////////
-(LHParallaxNode*) paralaxNodeWithUniqueName:(NSString*)uniqueName{
    return [parallaxesInLevel objectForKey:uniqueName];
}
//------------------------------------------------------------------------------
-(void) createParallaxes
{
    for(NSDictionary* parallaxDict in lhParallax){
		LHParallaxNode* node = [self parallaxNodeFromDictionary:parallaxDict layer:cocosLayer];
        if(nil != node){
			[parallaxesInLevel setObject:node forKey:[parallaxDict objectForKey:@"UniqueName"]];
		}
    }
}
//------------------------------------------------------------------------------
-(LHParallaxNode*) parallaxNodeFromDictionary:(NSDictionary*)parallaxDict 
                                        layer:(CCLayer*)layer 
{
	LHParallaxNode* node = [LHParallaxNode nodeWithDictionary:parallaxDict];
    
    if(layer != nil && node != nil){
        int z = [[parallaxDict objectForKey:@"ZOrder"] intValue];
        [layer addChild:node z:z];
    }
    NSArray* spritesInfo = [parallaxDict objectForKey:@"Sprites"];
    for(NSDictionary* sprInf in spritesInfo){
        float ratioX = [[sprInf objectForKey:@"RatioX"] floatValue];
        float ratioY = [[sprInf objectForKey:@"RatioY"] floatValue];
        NSString* sprName = [sprInf objectForKey:@"SpriteName"];
        
		LHSprite* spr = [self spriteWithUniqueName:sprName];
		if(nil != node && spr != nil){
			[node addChild:spr parallaxRatio:ccp(ratioX, ratioY)];
		}
    }
    return node;
}
//------------------------------------------------------------------------------
-(void) releaseAllParallaxes
{
	NSArray* keys = [parallaxesInLevel allKeys];
    
	for(NSString* key in keys){
		LHParallaxNode* par = [parallaxesInLevel objectForKey:key];
		if(nil != par){
            [par removeFromParentAndCleanup:YES];
		}
	}
	[parallaxesInLevel removeAllObjects];
    [parallaxesInLevel release];
    parallaxesInLevel = nil;
}
////////////////////////////////////////////////////////////////////////////////
//JOINTS
////////////////////////////////////////////////////////////////////////////////
-(LHJoint*) jointFromDictionary:(NSDictionary*)joint world:(b2World*)world
{
    b2Joint* boxJoint = 0;
    
	if(nil == joint)
		return 0;
	
	if(world == 0)
		return 0;
    
    LHSprite* sprA = [spritesInLevel objectForKey:[joint objectForKey:@"ObjectA"]];
    b2Body* bodyA = [sprA body];
	
    LHSprite* sprB = [spritesInLevel objectForKey:[joint objectForKey:@"ObjectB"]];
    b2Body* bodyB = [sprB body];
	
	if(NULL == bodyA || 
       NULL == bodyB )
		return NULL;
	
	CGPoint anchorA = LHPointFromString([joint objectForKey:@"AnchorA"]);
	CGPoint anchorB = LHPointFromString([joint objectForKey:@"AnchorB"]);
	
	bool collideConnected = [[joint objectForKey:@"CollideConnected"] boolValue];
	
    int tag = [[joint objectForKey:@"Tag"] intValue];
    int type = [[joint objectForKey:@"Type"] intValue];
    
	b2Vec2 posA, posB;
	
	float convertX = [[LHSettings sharedInstance] convertRatio].x;
	float convertY = [[LHSettings sharedInstance] convertRatio].y;
    
    if(![[joint objectForKey:@"CenterOfMass"] boolValue])
    {
        posA = b2Vec2((bodyA->GetWorldCenter().x*[[LHSettings sharedInstance] lhPtmRatio] + convertX*anchorA.x)/[[LHSettings sharedInstance] lhPtmRatio], 
                      (bodyA->GetWorldCenter().y*[[LHSettings sharedInstance] lhPtmRatio] - convertY*anchorA.y)/[[LHSettings sharedInstance] lhPtmRatio]);
        
        posB = b2Vec2((bodyB->GetWorldCenter().x*[[LHSettings sharedInstance] lhPtmRatio] + convertX*anchorB.x)/[[LHSettings sharedInstance] lhPtmRatio], 
                      (bodyB->GetWorldCenter().y*[[LHSettings sharedInstance] lhPtmRatio] - convertY*anchorB.y)/[[LHSettings sharedInstance] lhPtmRatio]);
    }
    else {		
        posA = bodyA->GetWorldCenter();
        posB = bodyB->GetWorldCenter();
    }
	
	if(0 != bodyA && 0 != bodyB)
	{
		switch (type)
		{
			case LH_DISTANCE_JOINT:
			{
				b2DistanceJointDef jointDef;
				
				jointDef.Initialize(bodyA, 
									bodyB, 
									posA,
									posB);
				
				jointDef.collideConnected = collideConnected;
				
				jointDef.frequencyHz = [[joint objectForKey:@"Frequency"] floatValue];
				jointDef.dampingRatio = [[joint objectForKey:@"Damping"] floatValue];
				
				if(0 != world)
				{
					boxJoint = (b2DistanceJoint*)world->CreateJoint(&jointDef);
				}
			}	
				break;
				
			case LH_REVOLUTE_JOINT:
			{
				b2RevoluteJointDef jointDef;
				
				jointDef.lowerAngle = CC_DEGREES_TO_RADIANS([[joint objectForKey:@"LowerAngle"] floatValue]);
				jointDef.upperAngle = CC_DEGREES_TO_RADIANS([[joint objectForKey:@"UpperAngle"] floatValue]);
				jointDef.motorSpeed = [[joint objectForKey:@"MotorSpeed"] floatValue]; //Usually in radians per second. ?????
				jointDef.maxMotorTorque = [[joint objectForKey:@"MaxTorque"] floatValue]; //Usually in N-m.  ?????
				jointDef.enableLimit = [[joint objectForKey:@"EnableLimit"] boolValue];
				jointDef.enableMotor = [[joint objectForKey:@"EnableMotor"] boolValue];
				jointDef.collideConnected = collideConnected;    
				
				jointDef.Initialize(bodyA, bodyB, posA);
				
				if(0 != world)
				{
					boxJoint = (b2RevoluteJoint*)world->CreateJoint(&jointDef);
				}
			}
				break;
				
			case LH_PRISMATIC_JOINT:
			{
				b2PrismaticJointDef jointDef;
				
				// Bouncy limit
				CGPoint axisPt = LHPointFromString([joint objectForKey:@"Axis"]);
				
				b2Vec2 axis(axisPt.x, axisPt.y);
				axis.Normalize();
				
				jointDef.Initialize(bodyA, bodyB, posA, axis);
				
				jointDef.motorSpeed = [[joint objectForKey:@"MotorSpeed"] floatValue];
				jointDef.maxMotorForce = [[joint objectForKey:@"MaxMotorForce"] floatValue];
				
				
				jointDef.lowerTranslation =  CC_DEGREES_TO_RADIANS([[joint objectForKey:@"LowerTranslation"] floatValue]);
				jointDef.upperTranslation = CC_DEGREES_TO_RADIANS([[joint objectForKey:@"UpperTranslation"] floatValue]);
				
				jointDef.enableMotor = [[joint objectForKey:@"EnableMotor"] boolValue];
				jointDef.enableLimit = [[joint objectForKey:@"EnableLimit"] boolValue];
				jointDef.collideConnected = collideConnected;   
				if(0 != world)
				{
					boxJoint = (b2PrismaticJoint*)world->CreateJoint(&jointDef);
				}
			}	
				break;
				
			case LH_PULLEY_JOINT:
			{
				b2PulleyJointDef jointDef;
				
				CGPoint grAnchorA = LHPointFromString([joint objectForKey:@"GroundAnchorA"]);
				CGPoint grAnchorB = LHPointFromString([joint objectForKey:@"GroundAnchorB"]);
				
				CGSize winSize = [[CCDirector sharedDirector] displaySizeInPixels];
				
				grAnchorA.y = winSize.height - convertY*grAnchorA.y;
				grAnchorB.y = winSize.height - convertY*grAnchorB.y;
				
				b2Vec2 groundAnchorA = b2Vec2(convertX*grAnchorA.x/[[LHSettings sharedInstance] lhPtmRatio], 
											  grAnchorA.y/[[LHSettings sharedInstance] lhPtmRatio]);
				
				b2Vec2 groundAnchorB = b2Vec2(convertX*grAnchorB.x/[[LHSettings sharedInstance] lhPtmRatio], 
											  grAnchorB.y/[[LHSettings sharedInstance] lhPtmRatio]);
				
				float ratio = [[joint objectForKey:@"Ratio"] floatValue];
				jointDef.Initialize(bodyA, bodyB, groundAnchorA, groundAnchorB, posA, posB, ratio);				
				jointDef.collideConnected = collideConnected;   
				
				if(0 != world)
				{
					boxJoint = (b2PulleyJoint*)world->CreateJoint(&jointDef);
				}
			}
				break;
				
			case LH_GEAR_JOINT:
			{
				b2GearJointDef jointDef;
				
				jointDef.bodyA = bodyB;
				jointDef.bodyB = bodyA;
				
				if(bodyA == 0)
					return 0;
				if(bodyB == 0)
					return 0;
				
                LHJoint* jointAObj = [self jointWithUniqueName:[joint objectForKey:@"JointA"]];
                b2Joint* jointA = [jointAObj joint];
                
                LHJoint* jointBObj = [self jointWithUniqueName:[joint objectForKey:@"JointB"]];
                b2Joint* jointB = [jointBObj joint];
                
				if(jointA == 0)
					return 0;
				if(jointB == 0)
					return 0;
				
				
				jointDef.joint1 = jointA;
				jointDef.joint2 = jointB;
				
				jointDef.ratio =[[joint objectForKey:@"Ratio"] floatValue];
				jointDef.collideConnected = collideConnected;
				if(0 != world)
				{
					boxJoint = (b2GearJoint*)world->CreateJoint(&jointDef);
				}
			}	
				break;
				
				
			case LH_WHEEL_JOINT: //aka line joint
			{
				b2WheelJointDef jointDef;
				
				CGPoint axisPt = LHPointFromString([joint objectForKey:@"Axis"]);
				b2Vec2 axis(axisPt.x, axisPt.y);
				axis.Normalize();
				
				jointDef.motorSpeed = [[joint objectForKey:@"MotorSpeed"] floatValue]; //Usually in radians per second. ?????
				jointDef.maxMotorTorque = [[joint objectForKey:@"MaxTorque"] floatValue]; //Usually in N-m.  ?????
				jointDef.enableMotor = [[joint objectForKey:@"EnableMotor"] boolValue];
				jointDef.frequencyHz = [[joint objectForKey:@"Frequency"] floatValue];
				jointDef.dampingRatio = [[joint objectForKey:@"Damping"] floatValue];
				
				jointDef.Initialize(bodyA, bodyB, posA, axis);
				jointDef.collideConnected = collideConnected; 
				
				if(0 != world)
				{
					boxJoint = (b2WheelJoint*)world->CreateJoint(&jointDef);
				}
			}
				break;				
			case LH_WELD_JOINT:
			{
				b2WeldJointDef jointDef;
				
				jointDef.frequencyHz = [[joint objectForKey:@"Frequency"] floatValue];
				jointDef.dampingRatio = [[joint objectForKey:@"Damping"] floatValue];
				
				jointDef.Initialize(bodyA, bodyB, posA);
				jointDef.collideConnected = collideConnected; 
				
				if(0 != world)
				{
					boxJoint = (b2WheelJoint*)world->CreateJoint(&jointDef);
				}
			}
				break;
				
			case LH_ROPE_JOINT: //NOT WORKING YET AS THE BOX2D JOINT FOR THIS TYPE IS A TEST JOINT
			{
				
				b2RopeJointDef jointDef;
				
				jointDef.localAnchorA = bodyA->GetPosition();
				jointDef.localAnchorB = bodyB->GetPosition();
				jointDef.bodyA = bodyA;
				jointDef.bodyB = bodyB;
				jointDef.maxLength = [[joint objectForKey:@"MaxLength"] floatValue];
				jointDef.collideConnected = collideConnected; 
				
				if(0 != world)
				{
					boxJoint = (b2RopeJoint*)world->CreateJoint(&jointDef);
				}
			}
				break;
				
			case LH_FRICTION_JOINT:
			{
				b2FrictionJointDef jointDef;
				
				jointDef.maxForce = [[joint objectForKey:@"MaxForce"] floatValue];
				jointDef.maxTorque = [[joint objectForKey:@"MaxTorque"] floatValue];
				
				jointDef.Initialize(bodyA, bodyB, posA);
				jointDef.collideConnected = collideConnected; 
				
				if(0 != world)
				{
					boxJoint = (b2FrictionJoint*)world->CreateJoint(&jointDef);
				}
				
			}
				break;
				
			default:
				NSLog(@"Unknown joint type in LevelHelper file.");
				break;
		}
	}
    
    LHJoint* levelJoint = [LHJoint jointWithUniqueName:[joint objectForKey:@"UniqueName"]];
    [levelJoint setTag:tag];
    [levelJoint setType:(LH_JOINT_TYPE)type];
    [levelJoint setJoint:boxJoint];
    boxJoint->SetUserData(levelJoint);
    
	return levelJoint;
}
//------------------------------------------------------------------------------
-(LHJoint*) jointWithUniqueName:(NSString*)name{
    return [jointsInLevel objectForKey:name];
}
//------------------------------------------------------------------------------
-(NSArray*) jointsWithTag:(enum LevelHelper_TAG)tag;{
	NSArray *keys = [jointsInLevel allKeys];
    NSMutableArray* jointsWithTag = [[[NSMutableArray alloc] init] autorelease];
	for(NSString* key in keys){
        LHJoint* levelJoint = [jointsInLevel objectForKey:key];
        if([levelJoint tag] == tag){
            [jointsWithTag addObject:levelJoint];
        }
	}
    return jointsWithTag;
}
//------------------------------------------------------------------------------
-(void) createJoints{
    
    for(NSDictionary* jointDict in lhJoints)
	{
		LHJoint* boxJoint = [self jointFromDictionary:jointDict world:box2dWorld];
		
		if(nil != boxJoint)
        {
			[jointsInLevel setObject:boxJoint
                              forKey:[jointDict objectForKey:@"UniqueName"]];	
		}
	}	
}
//------------------------------------------------------------------------------
-(bool) removeAllJoints{
	[jointsInLevel removeAllObjects];
    return true;
}
//------------------------------------------------------------------------------
-(void) releaseAllJoints{
    [self removeAllJoints];
    [jointsInLevel release];
    jointsInLevel = nil;
}
//------------------------------------------------------------------------------
-(void) removeJointsWithTag:(enum LevelHelper_TAG)tag{
	NSArray *keys = [jointsInLevel allKeys];
	for(NSString* key in keys){
		LHJoint* joint = [jointsInLevel objectForKey:key];
        if([joint tag] == tag){
            [jointsInLevel removeObjectForKey:key];
        }
	}
}
//------------------------------------------------------------------------------
-(bool) removeJoint:(LHJoint*)joint{
	if(0 == joint)
		return false;
    [jointsInLevel removeObjectForKey:[joint uniqueName]];
	return true;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


-(void) setCustomAttributesForPhysics:(NSDictionary*)spriteProp 
								 body:(b2Body*)body
							   sprite:(LHSprite*)sprite
{
    
}
-(void) setCustomAttributesForNonPhysics:(NSDictionary*)spriteProp 
                                  sprite:(LHSprite*)sprite
{
    
}

-(void) setCustomAttributesForBezierBodies:(NSDictionary*)bezierProp 
                                      node:(CCNode*)sprite body:(b2Body*)body
{
    
}
////////////////////////////////////////////////////////////////////////////////
-(void)loadLevelHelperSceneFile:(NSString*)levelFile inDirectory:(NSString*)subfolder imgSubfolder:(NSString*)imgFolder
{
	NSString *path = [[NSBundle mainBundle] pathForResource:levelFile ofType:@"plhs" inDirectory:subfolder]; 
	
	NSAssert(nil!=path, @"Invalid level file. Please add the LevelHelper scene file to Resource folder. Please do not add extension in the given string.");
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	[self processLevelFileFromDictionary:dictionary];
}

-(void)loadLevelHelperSceneFileFromWebAddress:(NSString*)webaddress
{	
	NSURL *url = [NSURL URLWithString:webaddress];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:url];
	
	if(dictionary == nil)
		NSLog(@"Provided web address is wrong or connection error.");
	
	[self processLevelFileFromDictionary:dictionary];
}

-(void) loadLevelHelperSceneFromDictionary:(NSDictionary*)levelDictionary 
							  imgSubfolder:(NSString*)imgFolder
{	
	[[LHSettings sharedInstance] setImageFolder:imgFolder];
	[self processLevelFileFromDictionary:levelDictionary];
}

-(void)processLevelFileFromDictionary:(NSDictionary*)dictionary
{
	if(nil == dictionary)
		return;
	
	bool fileInCorrectFormat =	[[dictionary objectForKey:@"Author"] isEqualToString:@"Bogdan Vladu"] && 
	[[dictionary objectForKey:@"CreatedWith"] isEqualToString:@"LevelHelper"];
	
	if(fileInCorrectFormat == false)
		NSLog(@"This file was not created with LevelHelper or file is damaged.");
	
    NSDictionary* scenePref = [dictionary objectForKey:@"ScenePreference"];
    safeFrame = LHPointFromString([scenePref objectForKey:@"SafeFrame"]);
    gameWorldRect = LHRectFromString([scenePref objectForKey:@"GameWorld"]);
    
	CGRect color = LHRectFromString([scenePref objectForKey:@"BackgroundColor"]);
	glClearColor(color.origin.x, color.origin.y, color.size.width, 1);
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
   
    [[LHSettings sharedInstance] setConvertRatio:CGPointMake(winSize.width/safeFrame.x, winSize.height/safeFrame.y)];
    
    float safeFrameDiagonal = sqrtf(safeFrame.x* safeFrame.x + safeFrame.y* safeFrame.y);
    float winDiagonal = sqrtf(winSize.width* winSize.width + winSize.height*winSize.height);
    float PTM_conversion = winDiagonal/safeFrameDiagonal;
    
    [LevelHelperLoader setMeterRatio:[[LHSettings sharedInstance] lhPtmRatio]*PTM_conversion];
    
	////////////////////////LOAD WORLD BOUNDARIES//////////////////////////////////////////////
	if(nil != [dictionary objectForKey:@"WBInfo"])
	{
		wb = [dictionary objectForKey:@"WBInfo"];
	}
	
	////////////////////////LOAD SPRITES////////////////////////////////////////////////////
    lhSprites = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"SPRITES_INFO"]];
	
	///////////////////////////LOAD BATCH IMAGES////////////////////////////////////////////
	NSArray* batchImages = [dictionary objectForKey:@"LoadedImages"];
	for(NSDictionary* imageInfo in batchImages)
	{
        NSString* image = [imageInfo objectForKey:@"Image"];
//        if (CC_CONTENT_SCALE_FACTOR() == 2) {
//            image = [image substringToIndex:[image length] - 4];
//            image = [image stringByAppendingString:@"-hd.png"];
//        }
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:[[LHSettings sharedInstance] imagePath:image]];
		
        LHBatch* bNode = [LHBatch batchWithUniqueName:image];
        [bNode setSpriteBatchNode:batch];
        [bNode setZ:[[imageInfo objectForKey:@"OrderZ"] intValue]];
        [batchNodesInLevel setObject:bNode forKey:image];		
	}
	
	///////////////////////LOAD JOINTS//////////////////////////////////////////////////////////
	lhJoints = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"JOINTS_INFO"]];	
	
    //////////////////////LOAD PARALLAX/////////////////////////////////////////
    lhParallax = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"PARALLAX_INFO"]];
    
    ////////////////////LOAD BEZIER/////////////////////////////////////////////
    lhBeziers = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"BEZIER_INFO"]];
    
    ////////////////////LOAD ANIMS//////////////////////////////////////////////
    lhAnims = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"ANIMS_INFO"]];
    
    gravity = LHPointFromString([dictionary objectForKey:@"Gravity"]);
}
////////////////////////////////////////////////////////////////////////////////////
@end
