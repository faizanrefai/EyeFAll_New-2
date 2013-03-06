//
//  GrowButton.h
//  Game
//
//  Created by hrh on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScaleMenu.h"

@interface GrowScaleButton : ScaleMenu 
{    
}

+ (GrowScaleButton*)buttonWithSprite:(NSString*)normalImage
					selectImage: (NSString*) selectImage
					  target:(id)target
					selector:(SEL)sel;

+ (GrowScaleButton*)buttonWithSpriteFrame:(NSString*)frameName 
						 selectframeName: (NSString*) selectframeName
						 target:(id)target
					   selector:(SEL)sel;

+ (CCMenuItem*)menuItemWithSprite:(NSString*)normalImage 
                      selectImage:(NSString *)selectImage
                           target:(id)target
                         selector:(SEL)sel;
@end
