//
//  ScaleMenu.mm
//  Mahjong_cc
//
//  Created by YunCholHo on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScaleMenu.h"
#import "ScaleMenuItemToggle.h"

@implementation ScaleMenu

/*
 * override add:
 */
-(void) addChild:(CCMenuItem*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	[super addChild:child z:z tag:aTag];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] scale] == 1) {
		if ([child isKindOfClass:[CCMenuItemSprite class]] ||
			[child isKindOfClass:[ScaleMenuItemToggle class]]) {
			child.scale *= 0.5f;
		}
	}
}

@end
