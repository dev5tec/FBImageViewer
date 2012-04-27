//
//  Created by Hiroshi Hashiguchi on 10/09/28.
//  Copyright 2010 . All rights reserved.
//

#import "FBImageViewerViewController.h"
#import "FBImageViewerInnerScrollView.h"

enum {
	kIndexOfPreviousScrollView = 0,
	kIndexOfCurrentScrollView,
	kIndexOfNextScrollView,
	kMaxOfScrollView
};

@implementation FBImageViewerViewController

@synthesize imageFiles = imageFiles_;
@synthesize galleryView = galleryView_;

#pragma mark -
#pragma mark UIViewController
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
//	self.galleryView.showcaseModeEnabled = NO;
//	self.galleryView.pageControlEnabled = NO;
//	self.galleryView.showcaseModeEnabled = YES;
//	self.galleryView.pageControlEnabled = YES;
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.imageFiles = nil;
}


#pragma mark -
#pragma mark FBImageViewerViewDataSource
-(NSInteger)numberOfImagesInImageViewerView:(FBImageViewerView*)imageViewerView
{
	return [self.imageFiles count];
}

-(UIImage*)imageViewerView:(FBImageViewerView*)imageViewerView imageAtIndex:(NSUInteger)index
{
	return [UIImage imageWithContentsOfFile:[self.imageFiles objectAtIndex:index]];
}

#pragma mark -
#pragma mark FBImageViewerViewDelegate
-(void)imageViewerViewDidStopSlideShow:(FBImageViewerView*)imageViewerView
{
	NSLog(@"didStopSlideShow:");
}


#pragma mark -
#pragma mark Event
- (IBAction)playSlideShow:(id)sender
{
	[self.galleryView startSlideShow];
}

- (IBAction)changeMode:(id)sender
{
	self.galleryView.showcaseModeEnabled = !self.galleryView.showcaseModeEnabled;
}

- (IBAction)movePage:(id)sender
{
	self.galleryView.currentIndex = 3;
//	[self.galleryView setCurrentPage:5 animated:NO];
}

- (IBAction)refresh:(id)sender
{
	NSLog(@"TODO %s", __PRETTY_FUNCTION__);
}

- (IBAction)deletePage:(id)sender
{
	if ([imageFiles_ count] > 0) {
		[imageFiles_ removeObjectAtIndex:self.galleryView.currentIndex];
		[self.galleryView removeCurrentIndexAimated:YES];
	}
}

- (IBAction)movePrevious:(id)sender
{
	[self.galleryView moveToPreviousIndexAnimated:YES];
}

- (IBAction)moveNext:(id)sender
{
	[self.galleryView moveToNextIndexAnimated:YES];
}

@end
