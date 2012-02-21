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

- (NSInteger)numberOfImagesInImageViewerView:(FBImageViewerView*)imageViewerView;
- (UIImage*)imageViewerView:(FBImageViewerView*)imageViewerView imageAtIndex:(NSUInteger)index;

@end

@protocol FBImageViewerViewDelegate <NSObject>
@optional
- (void)imageViewerView:(FBImageViewerView*)imageViwerView willMoveFromIndex:(NSUInteger)index;
- (void)imageViewerView:(FBImageViewerView*)imageViwerView didMoveToIndex:(NSUInteger)index;
- (void)imageViewerViewDidStopSlideShow:(FBImageViewerView*)imageViewerView;

@end


typedef enum {
    FBImageViewerViewPageControllerPositionTop = 0,
    FBImageViewerViewPageControllerPositionBottom,
} FBImageViewerViewPageControllerPosition;


@class FBImageViewerInnerScrollView;
@interface FBImageViewerView : UIView <UIScrollViewDelegate, FBImageViewerInnerScrollViewDelegate> {
	CGSize previousScrollSize_;
	
	BOOL showcaseModeEnabled_;
	BOOL showcaseModeEnabledBeforeSlideshow_;
	
	CGSize spacing_;
	CGSize margin_;
	
	BOOL didSetup_;
	
	// slide show status
	BOOL isRunningSlideShow_;
	NSTimeInterval slideShowDuration_;
	NSTimer* timer_;
	FBImageViewerInnerScrollView* transitionInnerScrollView_;
	
	BOOL passDidScroll_;
	BOOL scrollingAnimation_;
	
}

// public properties
@property (nonatomic, assign) IBOutlet id <FBImageViewerViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id <FBImageViewerViewDataSource> dataSource;
@property (nonatomic, assign) BOOL showcaseModeEnabled;
@property (nonatomic, assign) BOOL pageControlHidden;
@property (nonatomic, assign) FBImageViewerViewPageControllerPosition pageControlPosition;
@property (nonatomic, assign) BOOL isRunningSlideShow;
@property (nonatomic, assign) NSTimeInterval slideShowDuration;
@property (nonatomic, assign) NSInteger currentIndex;	// start with 0

// public methods
- (void)reloadData;
- (void)startSlideShow;
- (void)stopSlideShow;
- (void)setCurrentIndex:(NSInteger)page animated:(BOOL)animated;
- (void)moveToPreviousIndexAnimated:(BOOL)animated;
- (void)moveToNextIndexAnimated:(BOOL)animated;
- (void)moveToFirstIndexAnimated:(BOOL)animated;
- (void)moveToLastIndexAnimated:(BOOL)animated;
- (void)removeCurrentIndexAimated:(BOOL)animated;

@end
