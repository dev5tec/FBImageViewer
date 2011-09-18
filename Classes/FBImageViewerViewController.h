//
//  Created by Hiroshi Hashiguchi on 10/09/28.
//  Copyright 2010 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBImageViewerView.h"

@interface FBImageViewerViewController : UIViewController <FBImageViewerViewDelegate> {

	NSMutableArray* imageFiles_;
	
	FBImageViewerView* galleryView;
}

@property (nonatomic, retain) NSMutableArray* imageFiles;
@property (nonatomic, retain) IBOutlet FBImageViewerView* galleryView;
- (IBAction)playSlideShow:(id)sender;
- (IBAction)changeMode:(id)sender;
- (IBAction)movePage:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)deletePage:(id)sender;
- (IBAction)movePrevious:(id)sender;
- (IBAction)moveNext:(id)sender;
@end

