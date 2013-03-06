//
//  AppDelegate.m
//  Hello2
//
//  Created by Bogdan Vladu on 10/27/11.
//  Copyright Bogdan Vladu 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "LoadScene.h"
#import "RootViewController.h"
#import <time.h>
#import "LBViewController.h"
#import "AppSettings.h"

@implementation AppDelegate

@synthesize window;
@synthesize gameCenterManager;
@synthesize currentLeaderBoard;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	[viewController createAdMobView];
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
//	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	m_nCurWnd = WND_NONE;
    [self changeWindow:WND_TITLE];
    
    srand((unsigned int)time(NULL));
    
    if ([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
    
    // Facebook
	_permissions =  [[NSArray arrayWithObjects:@"status_update",nil] retain];	
	_session = [[Session alloc] init];
	_facebook = [[_session restore] retain];
	
	if (_facebook == nil) {
		NSLog(@"facebook == nil");
		_facebook = [[Facebook alloc] init];
		[self fbDidLogout];
	} else {
		NSLog(@"facebook != nil");
		[self fbDidLogin];
	}
	m_nTopScore = 0;
}

- (void) changeWindow:(WND_ID) wndNew {
	[self changeWindow: wndNew param1: -1 param2:-1];
}

- (void) changeWindow:(WND_ID) wndNew param:(int) param {
    [self changeWindow: wndNew param1: param param2:-1];
}

- (void) changeWindow:(WND_ID) wndNew param1:(int) param1 param2:(int) param2 {
    CCDirector*	director = [CCDirector sharedDirector];
    CCScene*	scene = nil;
    
    scene = [LoadScene scene:m_nCurWnd wndNew:wndNew param1:param1 param2:param2];
    if( scene ) {
        if (m_nCurWnd == WND_NONE) {
            [director runWithScene:scene];
        }
        else {
            CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0f scene:scene];
            [director replaceScene: ts];
        }
        m_nCurWnd = wndNew;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

#pragma mark GameCenter View Controllers
- (void) showLeaderboard
{
	LBViewController *leaderboardController = [[LBViewController alloc] init];
	if (leaderboardController != NULL) {
        switch ([AppSettings getPlayMode]) {
            case MODE_TIME:
                self.currentLeaderBoard = kEyeFallMTLeaderboardID;
                break;
            case MODE_DESTRUCTION:
                self.currentLeaderBoard = kEyeFallMDLeaderboardID;
                break;    
            default:
                break;
        }
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[viewController presentModalViewController: leaderboardController animated: YES];
		[leaderboardController release];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *) gkViewController{
	[gkViewController dismissModalViewControllerAnimated: YES];
}

- (IBAction) resetAchievements: (id) sender{
	[gameCenterManager resetAchievements];
}

- (void) submitScore: (int) nScore
{
    if (g_bTestMode) {
        return;
    }
	if(nScore > [AppSettings getMAXScore] && self.gameCenterManager )
	{
        [AppSettings setMAXScore:nScore];
        switch ([AppSettings getPlayMode]) {
            case MODE_TIME:
                self.currentLeaderBoard = kEyeFallMTLeaderboardID;
                break;
            case MODE_DESTRUCTION:
                self.currentLeaderBoard = kEyeFallMDLeaderboardID;
                break;    
            default:
                break;
        }
		[self.gameCenterManager reportScore: nScore forCategory: self.currentLeaderBoard];
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController 
{
}

-(void) OnFacebookClicked: (int) topScore {
	
	m_nTopScore = topScore;
	
	if (![_facebook isSessionValid]) {
		[self login];
	}
	else {
		[self SendQuoteToFacebook];
	}
}

#pragma mark Facebook

- (void)login {
	//m_TimeView.m_bFaceBookEnable = YES;
	[_facebook authorize:kFBAppId permissions:_permissions delegate:self];
}

- (void)cancelLogin {
	[_facebook logout:self]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

#pragma mark FacebookDelegate

/**
 * Callback for facebook login
 */ 
-(void) fbDidLogin {
	_userInfo = [[[[UserInfo alloc] initializeWithFacebook:_facebook andDelegate: self] 
				  autorelease] 
				 retain];
	[_userInfo requestAllInfo];
	
	[self SendQuoteToFacebook];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}

/**
 * Callback for facebook logout
 */ 
-(void) fbDidLogout {
}

/**
 * Callback when a request receives Response
 */ 

- (void) request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
	
}
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
};

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	NSLog(@"request didFailWithError: %@", [error localizedDescription]); 
	
	//	[self.label setText:[error localizedDescription]];
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	NSLog(@"request didLoad");
	/*	if ([result isKindOfClass:[NSArray class]]) {
	 result = [result objectAtIndex:0]; 
	 }
	 if ([result objectForKey:@"owner"]) {
	 //[self.label setText:@"Photo upload Success"];
	 } else {
	 //	[self.label setText:[result objectForKey:@"name"]];
	 }*/
};

/** 
 * Called when a UIServer Dialog successfully return
 */
- (void)dialogDidComplete:(FBDialog*)dialog{
	//[self.label setText:@"publish successfully"];
	UIAlertView* msgBox = [[UIAlertView alloc] initWithTitle:@"" message:@"post successfully!" 
													delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[msgBox show];
	[msgBox release];
}

- (void)userInfoDidLoad {
	NSLog(@"userInfoDidLoad");
	[_session setSessionWithFacebook:_facebook andUid:_userInfo.uid];
	[_session save];
}

- (void)userInfoFailToLoad {
	NSLog(@"userInfoDidLoad failed");
	[self cancelLogin];
}

-(void) SendQuoteToFacebook {
    
	
	NSString *msg = [NSString stringWithFormat:@"I've scored %d markets.", m_nTopScore];
    
	
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* aattachment = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"My Score", @"name",
								 msg, @"caption",
								 @"", @"description",
								 nil];
	
	NSString *attachmentStr = [jsonWriter stringWithObject:aattachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kFBAppId, @"api_key",
								   @"Share on Facebook",  @"user_message_prompt",
								   attachmentStr, @"attachment",
								   nil];
	
	[_facebook requestWithMethodName: @"stream.publish" 
						   andParams: params
					   andHttpMethod: @"POST" 
						 andDelegate: self]; 	 
}

@end
