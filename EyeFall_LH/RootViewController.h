//
//  RootViewController.h
//  EyeFall_LH
//
//  Created by YunCholHo on 1/18/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GADBannerView.h"

@interface RootViewController : UIViewController <GADBannerViewDelegate>{
    GADBannerView *adView;
}

- (void)createAdMobView;
@end
