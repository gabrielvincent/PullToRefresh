//
//  PullToRefreshViewController.h
//  PullToRefresh
//
//  Created by Gabriel Vincent on 28/04/12.
//  Copyright (c) 2012 _A_Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PullToRefreshViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate> {
	NSArray *data;
	UILabel *updateLabel;
	UIImageView *updateImageView;
	BOOL shouldUpdate;
	BOOL shouldPlaySound;
	NSOperationQueue *queue;
	float offset;
	BOOL isUpdating;
	UIActivityIndicatorView *spinner;
	UILabel *lastUpdateLabel;
	
	AVAudioPlayer *audio;
}

@end
