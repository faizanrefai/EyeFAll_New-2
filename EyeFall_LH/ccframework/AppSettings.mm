//
//  AppSetting.m
//  fruitGame
//
//  Created by KCU on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppSettings.h"


@implementation AppSettings

+ (void) defineUserDefaults
{
	NSString* userDefaultsValuesPath;
	NSDictionary* userDefaultsValuesDict;
	
	// load the default values for the user defaults
	userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
	userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile: userDefaultsValuesPath];
	[[NSUserDefaults standardUserDefaults] registerDefaults: userDefaultsValuesDict];
}

+ (void) setScore: (int) nworld nlevel:(int)nlevel nScore:(int64_t) nScore
{
    if (g_bTestMode) {
        return;
    }
    
    if ([AppSettings getScore:nworld nlevel:nlevel] >= nScore) {
        return;
    }
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* score  =	[NSNumber numberWithUnsignedLongLong: nScore];
    switch ([self getPlayMode]) {
        case MODE_TIME:
            [defaults setObject:score forKey:[NSString stringWithFormat:@"MT_Score_%d", nworld * LEVEL_COUNT + nlevel]];	
            break;
        case MODE_DESTRUCTION:
            [defaults setObject:score forKey:[NSString stringWithFormat:@"MD_Score_%d", nworld * LEVEL_COUNT + nlevel]];	
            break;
        default:
            break;
    }
	
	[NSUserDefaults resetStandardUserDefaults];	
}

+ (int64_t) getScore: (int) nworld nlevel:(int)nlevel
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* score;
    switch ([self getPlayMode]) {
        case MODE_TIME:
            score = [defaults objectForKey:[NSString stringWithFormat:@"MT_Score_%d", nworld * LEVEL_COUNT + nlevel]];
            break;
        case MODE_DESTRUCTION:
            score = [defaults objectForKey:[NSString stringWithFormat:@"MD_Score_%d", nworld * LEVEL_COUNT + nlevel]];
            break;
        default:
            break;
    }
    return [score unsignedLongLongValue];
}

+ (void) setMAXScore:(int)nMaxScore {
    if (g_bTestMode) {
        return;
    }
    
    if ([AppSettings getMAXScore] >= nMaxScore) {
        return;
    }
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* score  =	[NSNumber numberWithUnsignedLongLong: nMaxScore];
    switch ([self getPlayMode]) {
        case MODE_TIME:
            [defaults setObject:score forKey:@"MT_MAX_Score"];	
            break;
        case MODE_DESTRUCTION:
            [defaults setObject:score forKey:@"MD_MAX_Score"];
            break;
        default:
            break;
    }
	[NSUserDefaults resetStandardUserDefaults];	
}

+ (int64_t) getMAXScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* score;
    switch ([self getPlayMode]) {
        case MODE_TIME:
            score = [defaults objectForKey:@"MT_MAX_Score"];
            break;
        case MODE_DESTRUCTION:
            score = [defaults objectForKey:@"MD_MAX_Score"];
            break;
        default:
            break;
    }
    return [score unsignedLongLongValue];
}

+ (int64_t) getTotalMAXScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* score1, *score2;
    score1 = [defaults objectForKey:@"MT_MAX_Score"];
    score2 = [defaults objectForKey:@"MD_MAX_Score"];
    
    return [score1 unsignedLongLongValue] + [score2 unsignedLongLongValue];
}

+ (void) setBGMEnable: (BOOL) bBGMEnable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: bBGMEnable];	
	[defaults setObject:aFlag forKey:@"BGMEnable"];	
	[NSUserDefaults resetStandardUserDefaults];
}

+ (void) setEMEnable: (BOOL) bVolume {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: bVolume];	
	[defaults setObject:aFlag forKey:@"EMEnable"];	
	[NSUserDefaults resetStandardUserDefaults];
}

+ (BOOL) isBGMEnable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults boolForKey: @"BGMEnable"];
}

+ (BOOL) isEMEnable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults boolForKey: @"EMEnable"];
}

+ (void) setCurLevel:(int)nWorld level:(int)nLevel {
    if (g_bTestMode) {
        return;
    }
    
    if ([AppSettings getCurLevel:nWorld] >= nLevel) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: nLevel];	
    switch ([self getPlayMode]) {
        case MODE_TIME:
            [defaults setObject:aFlag forKey:[NSString stringWithFormat:@"MT_World%d", nWorld]];	
            break;
        case MODE_DESTRUCTION:
            [defaults setObject:aFlag forKey:[NSString stringWithFormat:@"MD_World%d", nWorld]];	
            break;
        default:
            break;
    }
	[NSUserDefaults resetStandardUserDefaults];
}

+ (int)  getCurLevel:(int)nWorld {
    if (g_bTestMode) {
        if (nWorld < 3) {
            return 12;
        }
        else
            return 0;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([self getPlayMode]) {
        case MODE_TIME:
            return [defaults integerForKey:[NSString stringWithFormat:@"MT_World%d", nWorld]];
            break;
        case MODE_DESTRUCTION:
            return [defaults integerForKey:[NSString stringWithFormat:@"MD_World%d", nWorld]];
            break;
        default:
            break;
    }
	return 0;
}

+ (void) setCurWorld:(int)nWorld {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: nWorld];
    switch ([self getPlayMode]) {
        case MODE_TIME:
            [defaults setObject:aFlag forKey:@"MT_CurrentWorld"];	
            break;
        case MODE_DESTRUCTION:
            [defaults setObject:aFlag forKey:@"MD_CurrentWorld"];	
            break;
        default:
            break;
    }
	
	[NSUserDefaults resetStandardUserDefaults];
}

+ (int)  getCurWorld {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
    switch ([self getPlayMode]) {
        case MODE_TIME:
            return [defaults integerForKey: @"MT_CurrentWorld"];
            break;
        case MODE_DESTRUCTION:
            return [defaults integerForKey: @"MD_CurrentWorld"];
            break;
        default:
            break;
    }
	return 0;	
}

+ (void) setPlayMode:(int)mode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: mode];	
	[defaults setObject:aFlag forKey:@"PlayMode"];	
	[NSUserDefaults resetStandardUserDefaults];
}

+ (int) getPlayMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults integerForKey:@"PlayMode"];
}
/*
+ (void) setBackgroundVolume: (float) fVolume
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aVolume  =	[[NSNumber alloc] initWithFloat: fVolume];	
	[defaults setObject:aVolume forKey:@"music"];	
	[NSUserDefaults resetStandardUserDefaults];	
}

+ (float) backgroundVolume
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults floatForKey:@"music"];
	
}

+ (void) setEffectVolume: (float) fVolume
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aVolume  =	[[NSNumber alloc] initWithFloat: fVolume];	
	[defaults setObject:aVolume forKey:@"effect"];	
	[NSUserDefaults resetStandardUserDefaults];	
}

+ (float) effectVolume
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults floatForKey:@"effect"];
	
}

+ (void) setLevelFlag: (int) index flag: (BOOL) flag
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: flag];	
	[defaults setObject:aFlag forKey:[NSString stringWithFormat: @"level%d", index]];	
	[NSUserDefaults resetStandardUserDefaults];		
}

+ (BOOL) getLevelFlag: (int) index
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults boolForKey: [NSString stringWithFormat: @"level%d", index]];	
}

+(void) setStartLevel: (int) index 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: index];	
	[defaults setObject:aFlag forKey: @"curLevel"];	
	[NSUserDefaults resetStandardUserDefaults];
}

+ (BOOL) getStartLevel
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults boolForKey: @"curLevel"];
}

+(void) setUseAccelFlag:(BOOL)bFlag
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aFlag  =	[NSNumber numberWithFloat: bFlag];	
	[defaults setObject:aFlag forKey:@"useAccelFlag"];	
	[NSUserDefaults resetStandardUserDefaults];
}

+(BOOL) getUseAccelFlag
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults boolForKey: @"useAccelFlag"];
}
*/
@end
