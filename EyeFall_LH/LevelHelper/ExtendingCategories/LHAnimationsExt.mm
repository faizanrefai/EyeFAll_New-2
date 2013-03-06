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

#import "LHAnimationsExt.h"
#import "LHAnimationNode.h"
#import "LHBatch.h"

@implementation LevelHelperLoader (ANIMATIONS_EXTENSION)
////////////////////////////////////////////////////////////////////////////////
-(void) startAnimationWithUniqueName:(NSString*)animName 
                            onSprite:(LHSprite*)ccsprite 
               endNotificationObject:(id)obj 
             endNotificationSelector:(SEL)sel{
    
    LHAnimationNode* animNode = [animationsInLevel objectForKey:animName];
    if(nil != animNode)
    {
        [animNode runAnimationOnSprite:ccsprite 
                       withNotifierObj:obj 
                           notifierSel:sel 
                           notifOnLoop:notifOnLoopForeverAnim];
    }
}
////////////////////////////////////////////////////////////////////////////////
-(void) nextFrameForSprite:(LHSprite*)ccsprite repeat:(bool)repeat
{
    if(ccsprite == nil)
        return;
    
    int curFrame = [ccsprite currentFrame];
    curFrame +=1;
    
    if(repeat && curFrame >= [ccsprite numberOfFrames])
    {
        curFrame = 0;
    }
    
    if(curFrame >= 0 && curFrame < [ccsprite numberOfFrames])
    {
        [ccsprite setFrame:curFrame];
    }    
}
////////////////////////////////////////////////////////////////////////////////
-(void) setFrame:(int)value onSprite:(LHSprite*)ccsprite{
    
    if(nil == ccsprite)
        return;
    
    if(value >= 0 && value < [ccsprite numberOfFrames]){
        [ccsprite setFrame:value];
    }    
}
////////////////////////////////////////////////////////////////////////////////
-(void) prevFrameForSprite:(LHSprite*)spr repeat:(bool)repeat{
    
    if(spr == nil)
        return;
    
    int curFrame = [spr currentFrame];
    curFrame -=1;
    
    if(repeat && curFrame < 0)
    {
        curFrame = [spr numberOfFrames] - 1;        
    }
    
    if(curFrame >= 0 && curFrame < (int)[spr numberOfFrames])
    {
        [spr setFrame:curFrame];
    }        
}
////////////////////////////////////////////////////////////////////////////////
-(int) numberOfFramesForSprite:(LHSprite*)sprite{
    
    if(nil == sprite)
        return -1;
    
    return [sprite numberOfFrames];
}
////////////////////////////////////////////////////////////////////////////////
-(bool) isSpriteAtLastFrame:(LHSprite*)sprite{
    if(nil == sprite)
        return false;
    return ([sprite numberOfFrames]-1 == [sprite currentFrame]);
}
+(NSString*) animationNameOnBody:(b2Body*)body
{
    LHSprite* spr = (LHSprite*)body->GetUserData();
    if(nil == spr)
        return nil;
    
    return [spr animationName];
}
////////////////////////////////////////////////////////////////////////////////
+(NSString*) animationNameOnSprite:(LHSprite*)sprite
{
    if(nil == sprite)
        return nil;
    
    return [sprite animationName];
}
////////////////////////////////////////////////////////////////////////////////
+(int) currentFrameOnSprite:(LHSprite*)sprite
{
    if(nil == sprite)
        return -1;
    
    return [sprite currentFrame];
}
////////////////////////////////////////////////////////////////////////////////
+(int) currentFrameOnBody:(b2Body*)body
{
    LHSprite* spr = (LHSprite*)body->GetUserData();
    
    if(nil == spr)
        return -1;
    
    return [spr currentFrame];
}
////////////////////////////////////////////////////////////////////////////////
-(void) startAnimationWithUniqueName:(NSString*)animName 
         onSpriteWithUniqueName:(NSString*)sprName
         endNotificationObject:(id)obj 
         endNotificationSelector:(SEL)sel{

    LHSprite* spr = [self spriteWithUniqueName:sprName];
    [self startAnimationWithUniqueName:animName 
                              onSprite:spr 
                 endNotificationObject:obj 
               endNotificationSelector:sel];
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) startAnimationWithUniqueName:(NSString*)animName 
              onSpriteWithUniqueName:(NSString*)sprName{
    
    LHSprite* spr = [self spriteWithUniqueName:sprName];
    [self startAnimationWithUniqueName:animName onSprite:spr];
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) prepareAnimationWithUniqueName:(NSString*)animName 
                onSpriteWithUniqueName:(NSString*)sprName{
    
    LHSprite* ccsprite = [self spriteWithUniqueName:sprName];	
    [self prepareAnimationWithUniqueName:animName onSprite:ccsprite];
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) stopAnimationOnSpriteWithUniqueName:(NSString*)sprName
{
    LHSprite* ccsprite = [self spriteWithUniqueName:sprName];	
    [self stopAnimationOnSprite:ccsprite];
}
////////////////////////////////////////////////////////////////////////////////
-(void) nextFrameForSprite:(LHSprite*)ccsprite
{
    [self nextFrameForSprite:ccsprite repeat:false];
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) nextFrameForSpriteWithUniqueName:(NSString*)sprName
{
    LHSprite* spr = [self spriteWithUniqueName:sprName];
    [self nextFrameForSprite:spr repeat:NO];
}
////////////////////////////////////////////////////////////////////////////////
-(void) nextFrameForSpriteWithUniqueName:(NSString*)sprName repeat:(bool)repeat
{
    LHSprite* spr = [self spriteWithUniqueName:sprName];
    [self nextFrameForSprite:spr repeat:repeat];    
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) setFrame:(int)value onSpriteWithUniqueName:(NSString*)uniqueName{
    LHSprite* spr = [self spriteWithUniqueName:uniqueName];
    [self setFrame:value onSprite:spr];
}
////////////////////////////////////////////////////////////////////////////////
-(void) prevFrameForSprite:(LHSprite*)spr{
    [self prevFrameForSprite:spr repeat:NO];
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
-(void) prevFrameForSpriteWithUniqueName:(NSString*)sprName{
    LHSprite* spr = [self spriteWithUniqueName:sprName];
    [self prevFrameForSprite:spr repeat:NO];
}
////////////////////////////////////////////////////////////////////////////////
-(void) prevFrameForSpriteWithUniqueName:(NSString*)sprName repeat:(bool)repeat{
    LHSprite* spr = [self spriteWithUniqueName:sprName];
    [self prevFrameForSprite:spr repeat:repeat];    
}
////////////////////////////////////////////////////////////////////////////////
-(int) numberOfFramesForBody:(b2Body*)body{
    LHSprite* spr = (LHSprite*)body->GetUserData();
    return [self numberOfFramesForSprite:spr];
}
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
-(bool) isBodyAtLastFrame:(b2Body*)body{
    LHSprite*spr = (LHSprite*)body->GetUserData();
    return [self isSpriteAtLastFrame:spr];
}
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
@end
