/*
 The MIT License
 
 Copyright (c) 2010 Five-technology Co.,Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "FBImageViewerInnerScrollView.h"

@class FBImageViewerView;
@protocol FBImageViewerViewDataSource

-(NSInteger)numberOfImagesInImageViewerView:(FBImageViewerView*)imageViewerView;
-(UIImage*)imageViewerView:(FBImageViewerView*)imageViewerView imageAtIndex:(NSUInteger)index;

@end

@protocol FBImageViewerViewDelegate

-(void)imageViewerDidStopSlideShow:(FBImageViewerView*)imageViewerView;

@end


@class FBImageViewerInnerScrollView;
@interface FBImageViewerView : UIView <UIScrollViewDelegate, FBImageViewerInnerScrollViewDelegate> {

	NSInteger currentImageIndex_;
	
	UIScrollView* scrollView_;
	NSInteger contentOffsetIndex_;
	
	NSMutableArray* innerScrollViews_;
	
	CGSize previousScrollSize_;
	
	
	id <FBImageViewerViewDataSource> dataSource_;
	id <FBImageViewerViewDelegate> delegate_;
	

	BOOL showcaseModeEnabled_;
	BOOL showcaseModeEnabledBeforeSlideshow_;
	
	CGSize showcaseMargin_;
	CGSize viewSpacing_;

	CGSize spacing_;
	CGSize margin_;
	
	BOOL didSetup_;
	
	BOOL pageControlEnabled_;
	UIPageControl* pageControl_;
	
	// slide show status
	BOOL isRunningSlideShow_;
	NSTimeInterval slideShowDuration_;
	NSTimer* timer_;
	FBImageViewerInnerScrollView* transitionInnerScrollView_;
	
	BOOL passDidScroll_;
	BOOL scrollingAnimation_;
	
    BOOL scaleAspectFillEnabled_;
}

// public properties
@property (nonatomic, assign) IBOutlet id <FBImageViewerViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id <FBImageViewerViewDataSource> dataSource;
@property (nonatomic, assign) BOOL showcaseModeEnabled;
@property (nonatomic, assign) BOOL pageControlEnabled;
@property (nonatomic, assign) BOOL isRunningSlideShow;
@property (nonatomic, assign) NSTimeInterval slideShowDuration;
@property (nonatomic, assign) NSInteger currentIndex;	// start with 0
@property (nonatomic, assign) BOOL scaleAspectFillEnabled;

// public methods
- (void)reloadData;
- (void)startSlideShow;
- (void)stopSlideShow;
- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated;
- (void)moveToPreviousPageAnimated:(BOOL)animated;
- (void)moveToNextPageAnimated:(BOOL)animated;
- (void)moveToFirstPageAnimated:(BOOL)animated;
- (void)moveToLastPageAnimated:(BOOL)animated;
- (void)removeCurrentPage;

@end
