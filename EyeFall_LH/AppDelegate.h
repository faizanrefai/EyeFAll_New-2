//
//  AppDelegate.h
//  Hello2
//
//  Created by Bogdan Vladu on 10/27/11.
//  Copyright Bogdan Vladu 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "AppSpecificValues.h"
#import "FBConnect.h"
#import "Session.h"
#import "UserInfo.h"

//#define USE_LOADING_SCENE
#define kFBAppId						@"207760805928174"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate,
GameCenterManagerDelegate,
GKAchievementViewControllerDelegate, 
GKLeaderboardViewControllerDelegate,
FBRequestDelegate,FBDialogDelegate,FBSessionDelegate, UserInfoLoadDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    
    WND_ID	m_nCurWnd;
    
    //GameCenter
	GameCenterManager* gameCenterManager;
	NSString* currentLeaderBoard;
    
    //Facebook
	Session *_session;
	UserInfo *_userInfo;
	Facebook* _facebook;
	NSArray* _permissions;
	NSString* attachment;
	int m_nTopScore;
}


@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) GameCenterManager* gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;

- (void) changeWindow:(WND_ID) wndNew;
- (void) changeWindow:(WND_ID) wndNew param:(int) param;
- (void) changeWindow:(WND_ID) wndNew param1:(int) param1 param2:(int) param2;

//Game Center
- (void) submitScore: (int) nScore;
- (void) showLeaderboard;

// Facebook
- (void) SendQuoteToFacebook;
- (void) login;
- (void) OnFacebookClicked: (int) topScore;

@end
