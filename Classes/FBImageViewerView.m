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

#import <QuartzCore/QuartzCore.h>

#import "FBImageViewerView.h"

#define FB_IMAGE_VIEWER_VIEW_DEFAULT_SPACING_WIDTH	40
#define FB_IMAGE_VIEWER_VIEW_DEFAULT_SPACING_HEIGHT	0
#define FB_IMAGE_VIEWER_VIEW_DEFAULT_MARGIN_HEIGHT	50
#define FB_IMAGE_VIEWER_VIEW_DEFAULT_MARGIN_WIDTH_RATE	0.2

#define FB_IMAGE_VIEWER_VIEW_DEFAULT_SLIDESHOW_DURATION 3
#define FB_IMAGE_VIEWER_VIEW_DEFAULT_TRANSITION_DURATION	0.75

#define kMaxOfScrollView			3
#define kLengthFromCetner			((kMaxOfScrollView-1)/2)
#define kIndexOfCurrentScrollView	((kMaxOfScrollView-1)/2)


// private properties
@interface FBImageViewerView()

@property (nonatomic, assign) NSInteger currentImageIndex;

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, assign) NSInteger contentOffsetIndex;

@property (nonatomic, retain) NSMutableArray* innerScrollViews;

@property (nonatomic, assign) CGSize showcaseMargin;
@property (nonatomic, assign) CGSize viewSpacing;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, retain) NSTimer* timer;

@property (nonatomic, retain) FBImageViewerInnerScrollView* transitionInnerScrollView;
@end



@implementation FBImageViewerView

@synthesize currentImageIndex = currentImageIndex_;
@synthesize scrollView = scrollView_;
@synthesize contentOffsetIndex = contentOffsetIndex_;
@synthesize innerScrollViews = innerScrollViews_;
@synthesize delegate = delegate_;
@synthesize dataSource = dataSource_;
@synthesize showcaseModeEnabled = showcaseModeEnabled_;
@synthesize showcaseMargin = showcaseMargin_;
@synthesize viewSpacing = viewSpacing_;
@synthesize pageControlHidden = pageControlHidden_;
@synthesize pageControlPosition = pageControlPosition_;
@synthesize pageControl = pageControl_;
@synthesize isRunningSlideShow = isRunningSlideShow_;
@synthesize slideShowDuration = slideShowDuration_;
@synthesize timer = timer_;
@synthesize transitionInnerScrollView = transitionInnerScrollView_;

#pragma mark -
#pragma mark private utilities
- (NSInteger)_numberOfImages
{
	NSInteger numberOfViews = [self.dataSource numberOfImagesInImageViewerView:self];
	if (numberOfViews < 0) {
		numberOfViews = 0;
	}
	return numberOfViews;
}

- (void)_resetZoomScrollView:(FBImageViewerInnerScrollView*)innerScrollView
{
	innerScrollView.zoomScale = 1.0;
	innerScrollView.contentOffset = CGPointZero;
}

- (void)_setImageAtIndex:(NSInteger)index toScrollView:(FBImageViewerInnerScrollView*)innerScrollView
{
	if (index < 0 || [self _numberOfImages] <= index) {
		innerScrollView.imageView.image = nil;
		return;
	}
	
	innerScrollView.imageView.image =
        [self.dataSource imageViewerView:self imageAtIndex:index];
	
	[self _resetZoomScrollView:innerScrollView];
}


- (void)_setupClips
{
	self.scrollView.clipsToBounds = NO;

	/*
	if (self.showcaseModeEnabled) {
		self.scrollView.clipsToBounds = NO;
	} else {
		self.scrollView.clipsToBounds = YES;
	}
	 */
}

- (void)_setupSpacingAndMargin
{
	if (self.showcaseModeEnabled) {
		spacing_ = self.viewSpacing;
		spacing_.width = spacing_.width / 2.0;
		margin_ = self.showcaseMargin;
	} else {
		spacing_ = self.viewSpacing;
		margin_ = CGSizeZero;
	}
}
- (void)_setupSpacingAndMarginAndClips
{
	[self _setupSpacingAndMargin];
	[self _setupClips];
}


- (CGRect)_baseFrame
{
	return CGRectInset(self.bounds, margin_.width, margin_.height);
}

- (CGSize)_unitSize
{
	CGSize size;
	if (self.showcaseModeEnabled) {
		size = self.scrollView.bounds.size;
	} else {
		size = self.bounds.size;
		size.width += spacing_.width;
	}
	return size;
}	

- (void)_relayoutBaseScrollView
{
	CGRect scrollViewFrame = [self _baseFrame];
	scrollViewFrame.origin.x -= spacing_.width/2.0;
	scrollViewFrame.size.width += spacing_.width;
	self.scrollView.frame =scrollViewFrame;	
}

- (void)_relayoutInnerScrollViews
{
	CGRect innerScrollViewFrame = CGRectZero;
	innerScrollViewFrame.size = [self _baseFrame].size;
	innerScrollViewFrame.origin.x = (self.contentOffsetIndex-kLengthFromCetner) * innerScrollViewFrame.size.width;
	if (self.showcaseModeEnabled) {
		innerScrollViewFrame.origin.x -= spacing_.width;
	}
		
	for (int i=0; i < kMaxOfScrollView; i++) {
		
		FBImageViewerInnerScrollView* innerScrollView = [self.innerScrollViews objectAtIndex:i];
	
		innerScrollViewFrame.origin.x += spacing_.width/2.0;	// left space

		innerScrollView.frame = innerScrollViewFrame;

		innerScrollViewFrame.origin.x += innerScrollViewFrame.size.width; // next
		
		innerScrollViewFrame.origin.x += spacing_.width/2.0;	// right space
	}
	
}

- (void)_relayoutViewsAnimated:(BOOL)animated
{
	passDidScroll_ = YES;

	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	[self _setupSpacingAndMargin];
	[self _relayoutBaseScrollView];
	[self _relayoutInnerScrollViews];
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)_setPageControlHidden:(BOOL)hidden
{
    CGFloat alpha = hidden ? 0.0 : 1.0;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.pageControl.alpha = alpha;
                     }];    
}


#pragma mark -
#pragma mark -
- (void)reloadData
{
	NSInteger numberOfViews = [self _numberOfImages];
	if (self.currentImageIndex >= numberOfViews) {
		if (numberOfViews == 0) {
			self.currentImageIndex = 0;
		} else {
			self.currentImageIndex = numberOfViews-1;
		}
		self.contentOffsetIndex = self.currentImageIndex;
	}
	
	for (int index=0; index < kMaxOfScrollView; index++) {
		[self _setImageAtIndex:self.currentImageIndex+index-kLengthFromCetner
                  toScrollView:[self.innerScrollViews objectAtIndex:index]];
	}
	
	self.pageControl.numberOfPages = numberOfViews;
	self.pageControl.currentPage = self.currentImageIndex;
    
    if (numberOfViews <= 1) {
        [self _setPageControlHidden:YES];
    } else {
        [self _setPageControlHidden:self.pageControlHidden];
    }
}



#pragma mark -
#pragma mark setup and layout subviews
- (void)setupSubViews
{	
	// initialize vars
	self.viewSpacing = CGSizeMake(
								  FB_IMAGE_VIEWER_VIEW_DEFAULT_SPACING_WIDTH, FB_IMAGE_VIEWER_VIEW_DEFAULT_SPACING_HEIGHT);
	self.showcaseMargin = CGSizeMake(
									 (int)(self.bounds.size.width * FB_IMAGE_VIEWER_VIEW_DEFAULT_MARGIN_WIDTH_RATE),
									 FB_IMAGE_VIEWER_VIEW_DEFAULT_MARGIN_HEIGHT);
	[self _setupSpacingAndMarginAndClips];
	
	// setup self view
	//-------------------------
	self.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin  |
		UIViewAutoresizingFlexibleWidth       |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin   |
		UIViewAutoresizingFlexibleHeight      |
		UIViewAutoresizingFlexibleBottomMargin;
	self.clipsToBounds = YES;
	
	
	// setup base scroll view
	//-------------------------	
	self.scrollView = [[[UIScrollView alloc] initWithFrame:[self _baseFrame]] autorelease];
	
	self.scrollView.delegate = self;
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.autoresizingMask =
		UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleHeight;
	[self _relayoutBaseScrollView];

	[self addSubview:self.scrollView];
	
	// setup internal scroll views
	//------------------------------
	CGRect innerScrollViewFrame = CGRectZero;
//	innerScrollViewFrame.size = [self baseFrame].size;

	self.innerScrollViews = [NSMutableArray array];
		
	for (int i=0; i < kMaxOfScrollView; i++) {
		
		FBImageViewerInnerScrollView* innerScrollView =
			[[FBImageViewerInnerScrollView alloc] initWithFrame:innerScrollViewFrame];
		innerScrollView.clipsToBounds = YES;
		innerScrollView.backgroundColor = self.backgroundColor;
		innerScrollView.innerScrollViewDelegate = self;
		
		// bind & store views
		[self.scrollView addSubview:innerScrollView];
		[self.innerScrollViews addObject:innerScrollView];
		
		// release all
		[innerScrollView release];
	}
	[self _relayoutInnerScrollViews];
	
	// setup temporary view for slideshow transition
	self.transitionInnerScrollView =
		[[[FBImageViewerInnerScrollView alloc]
		  initWithFrame:innerScrollViewFrame] autorelease];
	self.transitionInnerScrollView.hidden = YES;
	[self.scrollView addSubview:self.transitionInnerScrollView];

	// setup page control
	self.pageControl = [[[UIPageControl alloc] initWithFrame:CGRectZero] autorelease];
	self.pageControl.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin  |
		UIViewAutoresizingFlexibleWidth       |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin   |
		UIViewAutoresizingFlexibleHeight      |
		UIViewAutoresizingFlexibleBottomMargin;
	self.pageControl.hidesForSinglePage = NO;
	[self.pageControl addTarget:self
						 action:@selector(pageControlDidChange:)
			   forControlEvents:UIControlEventValueChanged];
	[self addSubview:self.pageControl];
    
    // re-layout
    self.pageControlPosition = pageControlPosition_;
}	

- (void)_layoutSubviewsWithSizeChecking:(BOOL)checking animated:(BOOL)animated
{
	if (!didSetup_) {
		// initialization for only first time
		[self setupSubViews];
		[self reloadData];
		didSetup_ = YES;
	}

	CGSize newSize;
	if (self.showcaseModeEnabled) {
		newSize = self.scrollView.bounds.size;
		newSize.width -= spacing_.width;
	} else {
		newSize = self.bounds.size;
	}
	CGSize oldSize = previousScrollSize_;

	if (checking && CGSizeEqualToSize(newSize, oldSize)) {
		return;
	}
	
	[self _setupSpacingAndMarginAndClips];
		
	previousScrollSize_ = newSize;
	CGSize newSizeWithSpace = newSize;
	newSizeWithSpace.width += spacing_.width;
	
	// save previous contentSize
	//--
	FBImageViewerInnerScrollView* currentScrollView =
		[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
	CGSize oldContentSize = currentScrollView.contentSize;
	CGPoint oldContentOffset = currentScrollView.contentOffset;
	
	CGFloat zoomScale = currentScrollView.zoomScale;
	
	// calculate ratio (center / size)
	CGPoint oldCenter;
	oldCenter.x = oldContentOffset.x + oldSize.width/2.0;
	oldCenter.y = oldContentOffset.y + oldSize.height/2.0;
	
	CGFloat ratioW = oldCenter.x / oldContentSize.width;
	CGFloat ratioH = oldCenter.y / oldContentSize.height;
	
	
	// set new origin and size to innerScrollViews
	//--
	CGFloat x = (self.contentOffsetIndex-kLengthFromCetner) * newSizeWithSpace.width;
	for (FBImageViewerInnerScrollView* scrollView in self.innerScrollViews) {

		x += spacing_.width/2.0;	// left space
		
		scrollView.frame = CGRectMake(x, 0, newSize.width, newSize.height);
		CGSize contentSize;
		if (scrollView == currentScrollView) {
			contentSize.width  = newSize.width  * scrollView.zoomScale;
			contentSize.height = newSize.height * scrollView.zoomScale;
		} else {
			contentSize = newSize;
		}
		scrollView.contentSize = contentSize;
		x += newSize.width;
		x += spacing_.width/2.0;	// right space
	}
	
	
	// adjust current scroll view for zooming
	//--
	if (zoomScale > 1.0) {
		CGSize newContentSize = currentScrollView.contentSize;
		
		CGPoint newCenter;
		newCenter.x = ratioW * newContentSize.width;
		newCenter.y = ratioH * newContentSize.height;
		
		CGPoint newContentOffset;
		newContentOffset.x = newCenter.x - newSize.width /2.0;
		newContentOffset.y = newCenter.y - newSize.height/2.0;
		currentScrollView.contentOffset = newContentOffset;

		/* DEBUG
		NSLog(@"oldContentSize  : %@", NSStringFromCGSize(oldContentSize));
		NSLog(@"oldContentOffset: %@", NSStringFromCGPoint(oldContentOffset));
		NSLog(@"ratio           : %f, %f", ratioW, ratioH);
		NSLog(@"oldCenter       : %@", NSStringFromCGPoint(oldCenter));
		NSLog(@"newCenter       : %@", NSStringFromCGPoint(newCenter));
		NSLog(@"newContentOffset: %@", NSStringFromCGPoint(newContentOffset));
		NSLog(@"-----");
		 */
	}
	
	// adjust content size and offset of base scrollView
	//--

	passDidScroll_ = YES;
	self.scrollView.contentSize = CGSizeMake(
		[self _numberOfImages]*newSizeWithSpace.width,
		newSize.height);

	passDidScroll_ = YES;
	/*
	self.scrollView.contentOffset = CGPointMake(
		self.contentOffsetIndex*newSizeWithSpace.width, 0);
	 */
	[self.scrollView setContentOffset:CGPointMake(
							  self.contentOffsetIndex*newSizeWithSpace.width, 0)
							 animated:animated];

    /*
	 NSLog(@"oldSize         : %@", NSStringFromCGSize(oldSize));
	 NSLog(@"newSize         : %@", NSStringFromCGSize(newSize));
	 NSLog(@"scrollView.frame: %@", NSStringFromCGRect(self.scrollView.frame));
	 NSLog(@"newSizeWithSpace:%@", NSStringFromCGSize(newSizeWithSpace));
    NSLog(@"scrollView.contentOffset: %@", NSStringFromCGPoint(self.scrollView.contentOffset));
     */
}

- (void)layoutSubviews
{
	[self _layoutSubviewsWithSizeChecking:YES animated:NO];
}


#pragma mark -
#pragma mark Initialization and deallocation
- (void)setup
{
	pageControlHidden_ = YES;
	showcaseModeEnabled_ = NO;
	
	isRunningSlideShow_ = NO;
	slideShowDuration_ = FB_IMAGE_VIEWER_VIEW_DEFAULT_SLIDESHOW_DURATION;
    
    self.backgroundColor = [UIColor blackColor];
    pageControlPosition_ = FBImageViewerViewPageControllerPositionBottom;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
		[self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setup];
    }
    return self;
}


- (void)dealloc {
	self.scrollView = nil;
	self.innerScrollViews = nil;
	self.pageControl = nil;
	self.timer = nil;
	self.transitionInnerScrollView = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Control Scroll

-(void)_setupPreviousImage
{
	FBImageViewerInnerScrollView* rightView =
		[self.innerScrollViews objectAtIndex:kMaxOfScrollView-1];
	FBImageViewerInnerScrollView* leftView = [self.innerScrollViews objectAtIndex:0];

	CGRect frame = leftView.frame;
	frame.origin.x -= frame.size.width + spacing_.width;
	rightView.frame = frame;

	[self.innerScrollViews removeObjectAtIndex:kMaxOfScrollView-1];
	[self.innerScrollViews insertObject:rightView atIndex:0];
	[self _setImageAtIndex:self.currentImageIndex-kLengthFromCetner toScrollView:rightView];

}

-(void)_setupNextImage
{
	FBImageViewerInnerScrollView* rightView =
		[self.innerScrollViews objectAtIndex:kMaxOfScrollView-1];
	FBImageViewerInnerScrollView* leftView = [self.innerScrollViews objectAtIndex:0];
	
	CGRect frame = rightView.frame;
	frame.origin.x += frame.size.width + spacing_.width;
	leftView.frame = frame;
	
	[self.innerScrollViews removeObjectAtIndex:0];
	[self.innerScrollViews addObject:leftView];
	[self _setImageAtIndex:self.currentImageIndex+kLengthFromCetner toScrollView:leftView];

}


#pragma mark -
#pragma mark Event
-(void)pageControlDidChange:(id)sender
{
	BOOL previous;
	if (self.pageControl.currentPage < self.currentImageIndex) {
		previous = YES;
	} else {
		previous = NO;
	}

	self.currentImageIndex = self.pageControl.currentPage;
	self.contentOffsetIndex = self.pageControl.currentPage;

	FBImageViewerInnerScrollView* currentScrollView = 
	[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
	[self _resetZoomScrollView:currentScrollView];	
	
	[UIView beginAnimations:nil context:nil];
	self.scrollView.contentOffset = CGPointMake(
			self.contentOffsetIndex*[self _unitSize].width, 0);
	[UIView commitAnimations];
	
	if (previous) {
		[self _setupPreviousImage];
	} else {
		[self _setupNextImage];
	}
}


#pragma mark -
#pragma mark Slide Show 
- (void)stopSlideShow
{
	if (self.isRunningSlideShow && self.timer && [self.timer isValid]) {
		[self.timer invalidate];
		self.isRunningSlideShow = NO;	
		
		// don't use porperty
		// self.showcaseModeEnabled = showcaseModeEnabledBeforeSlideshow_;
		if (self.showcaseModeEnabled != showcaseModeEnabledBeforeSlideshow_) {
			[self setShowcaseModeEnabled:showcaseModeEnabledBeforeSlideshow_];
		}
		
        if ([self.delegate respondsToSelector:@selector(imageViewerViewDidStopSlideShow:)]) {
            [self.delegate imageViewerViewDidStopSlideShow:self];
        }
	} else {
		// nothing
	}

}

- (void)nextSlideShow:(NSTimer*)timer
{
	NSInteger numberOfViews = [self _numberOfImages];
	if (numberOfViews <= (self.currentImageIndex+1)) {
		[self stopSlideShow];
		return;
		// abort
	}

	// [1] setup transitionView
	[self _setImageAtIndex:self.currentImageIndex
			 toScrollView:self.transitionInnerScrollView];
	self.currentImageIndex = self.currentImageIndex + 1;
	
	self.contentOffsetIndex = self.contentOffsetIndex + 1;
	FBImageViewerInnerScrollView* nextInnerScrollView =
		[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
	
	self.transitionInnerScrollView.frame = nextInnerScrollView.frame;
	
	nextInnerScrollView.hidden = YES;
	self.transitionInnerScrollView.hidden = NO;

	self.scrollView.contentOffset = CGPointMake(self.contentOffsetIndex*self.scrollView.bounds.size.width, 0);

	
	// [2] do transition
	CATransition* transition = [CATransition animation];
	transition.duration = FB_IMAGE_VIEWER_VIEW_DEFAULT_TRANSITION_DURATION;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	transition.delegate = self;
	
	[self.scrollView.layer addAnimation:transition forKey:nil];

//	nextInnerScrollView.hidden = YES;
//	self.transitionInnerScrollView.hidden = NO;
	
	[self.innerScrollViews replaceObjectAtIndex:kIndexOfCurrentScrollView
									 withObject:self.transitionInnerScrollView];
	self.transitionInnerScrollView = nextInnerScrollView;

	// [3] setup next
	[self _setupNextImage];
}

- (void)startSlideShow
{
	if (self.isRunningSlideShow) {
		return;
	}
	
	showcaseModeEnabledBeforeSlideshow_ = self.showcaseModeEnabled;
	if (self.showcaseModeEnabled) {
		self.showcaseModeEnabled = NO;
	}
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.slideShowDuration
												  target:self
												selector:@selector(nextSlideShow:)
												userInfo:nil
												 repeats:YES];
	self.isRunningSlideShow = YES;
}


#pragma mark -
#pragma mark Delegate methods for CAAnimation
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(imageViewerView:didMoveToIndex:)]) {
        [self.delegate imageViewerView:self didMoveToIndex:self.currentImageIndex];
    }
}


#pragma mark -
#pragma mark FBImageViewerInnerScrollViewDelegate

- (void)didTouched:(FBImageViewerInnerScrollView*)innerScrollView
{
	[self stopSlideShow];
}

- (void)didDoubleTouched:(FBImageViewerInnerScrollView*)innerScrollView
{
	FBImageViewerInnerScrollView* currentScrollView = 
        [self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
    
    if (currentScrollView.zoomScale == 1.0) {
        [currentScrollView setZoomScale:2.0 animated:YES];
    } else {
        [currentScrollView setZoomScale:1.0 animated:YES];        
    }
}

- (BOOL)canZoom
{
	return !self.showcaseModeEnabled;
}


#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self stopSlideShow];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (passDidScroll_) {
		passDidScroll_ = NO;
		return;
	}

	CGFloat position = scrollView.contentOffset.x / scrollView.bounds.size.width;
	CGFloat delta = position - (CGFloat)self.currentImageIndex;
	
	if (fabs(delta) >= 1.0f) {
		FBImageViewerInnerScrollView* currentScrollView =
			[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
		[self _resetZoomScrollView:currentScrollView];
		
		//		NSLog(@"%f (%d=>%d)", delta, self.currentImageIndex, index);
        
        
        if ([self.delegate respondsToSelector:@selector(imageViewerView:willMoveFromIndex:)]) {
            [self.delegate imageViewerView:self willMoveFromIndex:self.currentImageIndex];
        }

		if (delta > 0) {
			// the current page moved to right
			self.currentImageIndex = self.currentImageIndex+1;
			self.contentOffsetIndex = self.contentOffsetIndex+1;
			self.pageControl.currentPage = self.currentImageIndex;
			[self _setupNextImage];
			
		} else {
			// the current page moved to left
			self.currentImageIndex = self.currentImageIndex-1;
			self.contentOffsetIndex = self.contentOffsetIndex-1;
			self.pageControl.currentPage = self.currentImageIndex;
			[self _setupPreviousImage];
		}
		
	}
	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	scrollingAnimation_ = NO;
}

#pragma mark -
#pragma mark change mode

- (void)setShowcaseModeEnabled:(BOOL)enabled animated:(BOOL)animated
{
	if (showcaseModeEnabled_ == enabled) {
		return;
	}

	// must be first !
	if (enabled) {
		FBImageViewerInnerScrollView* innerScrollView =
			[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
		innerScrollView.zoomScale = 1.0;
	}
	
	[self stopSlideShow];
	
	showcaseModeEnabled_ = enabled;

	[self _relayoutViewsAnimated:animated];
}


- (void)setShowcaseModeEnabled:(BOOL)enabled
{
	[self setShowcaseModeEnabled:enabled animated:YES];
}


#pragma mark -
#pragma mark public methods
- (void)setDataSource:(id <FBImageViewerViewDataSource>)dataSource
{
    dataSource_ = dataSource;
	[self reloadData];
}

- (void)setPageControlHidden:(BOOL)hidden
{
	pageControlHidden_ = hidden;
    if ([self _numberOfImages] <= 1) {
        [self _setPageControlHidden:YES];
    } else {
        [self _setPageControlHidden:hidden];
    }
}

- (void)setCurrentIndex:(NSInteger)page animated:(BOOL)animated
{
    if ([self _numberOfImages] == 0) {
        return;
    }

	NSInteger numberOfViews = [self _numberOfImages];

	if (page < 0) {
		page = 0;
	} else if (page >= numberOfViews) {
		page = numberOfViews - 1;
	}

    if (page == self.currentImageIndex) {
		return;
	}

	self.currentImageIndex = page;
	self.contentOffsetIndex = page;
	self.pageControl.currentPage = page;
	
	for (int index=0; index < kMaxOfScrollView; index++) {
		[self _setImageAtIndex:self.currentImageIndex+index-kLengthFromCetner
				 toScrollView:[self.innerScrollViews objectAtIndex:index]];
	}
	

	[self _relayoutViewsAnimated:NO];
	[self _layoutSubviewsWithSizeChecking:NO animated:animated];

}

- (void)_movePage:(BOOL)animated
{
	passDidScroll_ = YES;
	scrollingAnimation_ = YES;
	[self.scrollView setContentOffset:CGPointMake(
		self.contentOffsetIndex*[self _unitSize].width, 0)
							 animated:animated];
}

- (void)moveToPreviousIndexAnimated:(BOOL)animated
{
	if (scrollingAnimation_ || self.currentIndex <= 0) {
		// do nothing
		return;
	}
	
	self.currentImageIndex--;
	self.contentOffsetIndex--;
	self.pageControl.currentPage--;
	[self _setupPreviousImage];
	[self _movePage:animated];
}

- (void)moveToNextIndexAnimated:(BOOL)animated
{
	if (scrollingAnimation_ || self.currentIndex >= [self _numberOfImages]-1) {
		// do nothing
		return;
	}

	self.currentImageIndex++;
	self.contentOffsetIndex++;
	self.pageControl.currentPage++;
	[self _setupNextImage];
	[self _movePage:animated];
}

- (void)moveToFirstIndexAnimated:(BOOL)animated
{
    [self setCurrentIndex:0 animated:animated];
}

- (void)moveToLastIndexAnimated:(BOOL)animated
{
    [self setCurrentIndex:[self _numberOfImages]-1 animated:animated];    
}

//- (void)removeCurrentPage1
//{
//	[self reloadData];
//	[self _layoutSubviewsWithSizeChecking:NO animated:NO];
//}

- (void)removeCurrentIndexAimated:(BOOL)animated
{
	NSInteger numberOfImages = [self _numberOfImages];
	CGFloat directionFactor = 1.0;

	NSInteger transitionIndex = self.currentImageIndex;
	if (numberOfImages == 0) {
		transitionIndex = -1;
	} else if (numberOfImages == self.currentImageIndex) {
		transitionIndex--;
		directionFactor = -1.0;
	} else {
	}
	
	// [1] setup transitionView
	[self _setImageAtIndex:transitionIndex
			 toScrollView:self.transitionInnerScrollView];
	
	FBImageViewerInnerScrollView* currentInnerScrollView =
		[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView];
	
	self.transitionInnerScrollView.frame = currentInnerScrollView.frame;
	
	[self reloadData];
	
	// [2] do transition
	if (self.showcaseModeEnabled) {
//		self.transitionInnerScrollView.hidden = NO;

		// [2-1] setup init position
		FBImageViewerInnerScrollView* nextInnerScrollView =
			[self.innerScrollViews objectAtIndex:kIndexOfCurrentScrollView+1];
		CGFloat dw = 2 * [self _unitSize].width * directionFactor;
		CGRect frame;

		frame = currentInnerScrollView.frame;
		frame.origin.x += dw;
		currentInnerScrollView.frame = frame;
		frame = nextInnerScrollView.frame;
		frame.origin.x += dw;
		nextInnerScrollView.frame = frame;

		// [2-2] do animation
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            frame = currentInnerScrollView.frame;
            frame.origin.x -= dw;
            currentInnerScrollView.frame = frame;
            frame = nextInnerScrollView.frame;
            frame.origin.x -= dw;
            nextInnerScrollView.frame = frame;
    //		self.transitionInnerScrollView.hidden = YES;
            [UIView commitAnimations];
        }
	} else {
        if (animated) {
            CATransition* transition = [CATransition animation];
            transition.duration = FB_IMAGE_VIEWER_VIEW_DEFAULT_TRANSITION_DURATION;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
    //		transition.delegate = self;
            
            [self.scrollView.layer addAnimation:transition forKey:nil];
        }

		currentInnerScrollView.hidden = YES;
		self.transitionInnerScrollView.hidden = NO;

		[self.innerScrollViews replaceObjectAtIndex:kIndexOfCurrentScrollView
										 withObject:self.transitionInnerScrollView];
		self.transitionInnerScrollView = currentInnerScrollView;
	}
	
	// [3] re-layout subviews
	[self _layoutSubviewsWithSizeChecking:NO animated:NO];
    
    // [4] notify
    if (numberOfImages &&
        [self.delegate respondsToSelector:@selector(imageViewerView:didMoveToIndex:)]) {
        [self.delegate imageViewerView:self didMoveToIndex:self.currentImageIndex];
    }
}


#pragma mark -
#pragma mark Properties
- (void)setCurrentIndex:(NSInteger)page
{
	[self setCurrentIndex:page animated:YES];
}

- (NSInteger)currentIndex
{
	return currentImageIndex_;
}

- (void)setCurrentImageIndex:(NSInteger)currentImageIndex
{
    currentImageIndex_ = currentImageIndex;
    if ([self.delegate respondsToSelector:@selector(imageViewerView:didMoveToIndex:)]) {
        [self.delegate imageViewerView:self didMoveToIndex:currentImageIndex_];
    }
}



- (void)setPageControlPosition:(FBImageViewerViewPageControllerPosition)pageControlPosition
{
    pageControlPosition_ = pageControlPosition;
    CGFloat y;
    switch (pageControlPosition_) {
        case FBImageViewerViewPageControllerPositionTop:
            y = 0;
            break;
            
        case FBImageViewerViewPageControllerPositionBottom:
        default:
            y = self.bounds.size.height-FB_IMAGE_VIEWER_VIEW_DEFAULT_MARGIN_HEIGHT;
            break;
    }
	self.pageControl.frame = CGRectMake(0, y, self.bounds.size.width, FB_IMAGE_VIEWER_VIEW_DEFAULT_MARGIN_HEIGHT);
}

@end
