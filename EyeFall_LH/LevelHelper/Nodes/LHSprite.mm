//  This file was generated by LevelHelper
//  http://www.levelhelper.org
//
//  LevelHelperLoader.mm
//  Created by Bogdan Vladu
//  Copyright 2011 Bogdan Vladu. All rights reserved.
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
#import "LHSprite.h"
#import "LHSettings.h"
#import "LHAnimationNode.h"
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface LHSprite (Private)

@end
////////////////////////////////////////////////////////////////////////////////
@implementation LHSprite
////////////////////////////////////////////////////////////////////////////////
//-(oneway void) release{
//    
//    NSLog(@"LH Sprite RELEASE %@", uniqueName);
//    
//    [super release];
//}
-(void) dealloc{		
    
//    NSLog(@"LH Sprite Dealloc %@", uniqueName);

    [self stopAllActions];
    [self removeBodyFromWorld];

    [uniqueName release];
    [customUserValues release];
	[super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
-(void) generalLHSpriteInit{
    body = NULL;
    uniqueName = [[NSMutableString alloc] init];
    customUserValues = [[NSMutableDictionary alloc] init];
    
    currentFrame = 0;
    pathNode = nil;
}
-(id) init{
    self = [super init];
    if (self != nil)
    {
        [self generalLHSpriteInit];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////
+(id) spriteWithTexture:(CCTexture2D*)texture{
    return [[[self alloc] initWithTexture:texture] autorelease];
}
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect{
    return [[[self alloc] initWithTexture:texture rect:rect] autorelease];
}
+(id) spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame{
    return [[[self alloc] initWithSpriteFrame:spriteFrame] autorelease];
}
+(id) spriteWithSpriteFrameName:(NSString*)spriteFrameName{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName] autorelease];
}
+(id) spriteWithFile:(NSString*)filename{
    return [[[self alloc] initWithFile:filename] autorelease];
}
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect{
    return [[[self alloc] initWithFile:filename rect:rect] autorelease];
}
+(id) spriteWithCGImage: (CGImageRef)image key:(NSString*)key{
    return [[[self alloc] initWithCGImage:image key:key] autorelease];
}
+(id) spriteWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect{
    return [[[self alloc] initWithBatchNode:batchNode rect:rect] autorelease];
}
////////////////////////////////////////////////////////////////////////////////
-(id) initWithTexture:(CCTexture2D*)texture{

    self = [super initWithTexture:texture];
	if (self != nil)
	{
		//[self generalLHSpriteInit];
	}
	return self;
}
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect{

    self = [super initWithTexture:texture rect:rect];
	if (self != nil)
	{
		//[self generalLHSpriteInit];
	}
	return self;
}
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame{

    self = [super initWithSpriteFrame:spriteFrame];
	if (self != nil)
	{
		//[self generalLHSpriteInit];
	}
	return self;
}
-(id) initWithSpriteFrameName:(NSString*)spriteFrameName{
    self = [super initWithSpriteFrameName:spriteFrameName];
	if (self != nil)
	{
		//[self generalLHSpriteInit];
	}
	return self;    
}
-(id) initWithFile:(NSString*)filename{
    self = [super initWithFile:filename];
    if (self != nil)
    {
        //[self generalLHSpriteInit];        
    }
    return self;
}
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect{
    self = [super initWithFile:filename rect:rect];
    if (self != nil)
    {
        //[self generalLHSpriteInit];
    }
    return self;
}
-(id) initWithCGImage:(CGImageRef)image key:(NSString*)key{
    self = [super initWithCGImage:image key:key];
    if (self != nil)
    {
       // [self generalLHSpriteInit];
    }
    return self;
}
-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect{
    self = [super initWithBatchNode:batchNode rect:rect];
    if (self != nil)
    {
       // [self generalLHSpriteInit];
    }
    return self;
}
-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rectInPixels:(CGRect)rect{
    self = [super initWithBatchNode:batchNode rectInPixels:rect];
    if (self != nil)
    {
       // [self generalLHSpriteInit];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////
-(void) setUniqueName:(NSString*)name{
    NSAssert(name!=nil, @"UniqueName must not be nil");

    [uniqueName setString:name];
}
-(NSString*)uniqueName{
    return uniqueName;   
}
////////////////////////////////////////////////////////////////////////////////
-(void) setBody:(b2Body*)bd{
    NSAssert(bd!=nil, @"b2Body must not be nil");
    
    body = bd;
}
-(b2Body*)body{
    return body;
}
-(bool) removeBodyFromWorld{
    
    if(NULL != body)
	{
		b2World* _world = body->GetWorld();
		if(0 != _world)
		{
			_world->DestroyBody(body);
			body = NULL;
            
            return true;
		}
	}
    
    return false;
}
////////////////////////////////////////////////////////////////////////////////
-(void) setAnimation:(LHAnimationNode*)anim{
    animation = anim;
    if(nil != anim)
    {
        [anim setAnimationTexturePropertiesOnSprite:self];
        [self setFrame:0];
    }
}
-(LHAnimationNode*)animation{
    return animation;
}
-(NSString*) animationName{
    if(nil != animation)
        return [animation uniqueName];
    
    return @"";
}
-(int) numberOfFrames{
    if(nil != animation)
        return [animation numberOfFrames];
    
    return -1;
}
////////////////////////////////////////////////////////////////////////////////
-(void) setFrame:(int)frmNo{
    
    if(animation == nil)
        return;
    
    [animation setFrame:frmNo onSprite:self];
    currentFrame = frmNo;
}
-(int) currentFrame{
    return currentFrame;
}
////////////////////////////////////////////////////////////////////////////////
-(void) setPathNode:(LHPathNode*)node{
    NSAssert(node!=nil, @"LHPathNode must not be nil");    
    pathNode = node;
}
-(LHPathNode*)pathNode{
    return pathNode;
}
////////////////////////////////////////////////////////////////////////////////
-(void) setCustomValue:(id)value withKey:(NSString*)key{
    
    NSAssert(value!=nil, @"Custom value object must not be nil");    
    NSAssert(key!=nil, @"Custom value key must not be nil");    
    
    [customUserValues setObject:value forKey:key];
}
-(id) customValueWithKey:(NSString*)key{
    NSAssert(key!=nil, @"Custom value key must not be nil");    
    return [customUserValues objectForKey:key];
}
////////////////////////////////////////////////////////////////////////////////
@end
