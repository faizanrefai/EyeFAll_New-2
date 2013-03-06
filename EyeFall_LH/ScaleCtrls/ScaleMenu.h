//
//  ScaleMenu.h
//  Mahjong_cc
//
//  Created by YunCholHo on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ScaleMenu : CCMenu {

}

-(void) addChild:(CCMenuItem*)child z:(NSInteger)z tag:(NSInteger) aTag;

@end
