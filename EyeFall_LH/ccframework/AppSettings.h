//
//  AppSetting.h
//  fruitGame
//
//  Created by KCU on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"

@interface AppSettings : NSObject 
{

}

+ (void) defineUserDefaults;

+ (void) setBGMEnable: (BOOL) bBGMEnable;
+ (void) setEMEnable: (BOOL) bVolume;
+ (BOOL) isBGMEnable;
+ (BOOL) isEMEnable;
+ (void) setCurLevel:(int)nWorld level:(int)nLevel;
+ (int)  getCurLevel:(int)nWorld;
+ (void) setCurWorld:(int)nWorld;
+ (int)  getCurWorld;
/*+ (void) setLevelFlag: (int) index flag: (BOOL) flag;
+ (BOOL) getLevelFlag: (int) index;
+ (void) setStartLevel: (int) index;
+ (BOOL) getStartLevel;
+ (void) setUseAccelFlag: (BOOL) bFlag;
+ (BOOL) getUseAccelFlag;
 */
+ (void) setScore: (int) nworld nlevel:(int)nlevel nScore:(int64_t) nScore;
+ (int64_t) getScore: (int) nworld nlevel:(int)nlevel;

+ (void) setPlayMode:(int)mode;
+ (int) getPlayMode;

+ (void) setMAXScore:(int)nMaxScore;
+ (int64_t) getMAXScore;

+ (int64_t) getTotalMAXScore;
@end
