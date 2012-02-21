//
//  ImageScrollView.m
//  EasyGallery
//
//  Created by Hiroshi Hashiguchi on 10/10/04.
//
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

#import "FBImageViewerInnerScrollView.h"


@implementation FBImageViewerInnerScrollView

@synthesize imageView = imageView_;
@synthesize innerScrollViewDelegate = innerScrollViewDelegate_;

-(id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		
		// setup scrollview
//		[self setUserInteractionEnabled:YES];
		self.delegate = self;
		self.minimumZoomScale = 1.0;
		self.maximumZoomScale = 5.0;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.backgroundColor = [UIColor blackColor];
		self.clipsToBounds = YES;
		
		// setup imageview
		self.imageView =
			[[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		self.imageView.autoresizingMask =
			UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		[self addSubview:self.imageView];		
	}
	return self;
}


+ (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView
					  withScale:(float)scale withCenter:(CGPoint)center {
	
    CGRect zoomRect;
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
	zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
	
    return zoomRect;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.innerScrollViewDelegate didTouched:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.innerScrollViewDelegate didTouched:self];
	
	UITouch* touch = [touches anyObject];
	if ([touch tapCount] == 2) {
		[self.innerScrollViewDelegate didDoubleTouched:self];

		/*
		CGRect zoomRect;
		if (self.zoomScale > 1.0) {
			zoomRect = self.bounds;
		} else {
			zoomRect = [FTGalleryInnerScrollView zoomRectForScrollView:self
													withScale:2.0
												   withCenter:[touch locationInView:self]];
		}
		[self zoomToRect:zoomRect animated:YES];
		*/
	}
}

- (void) dealloc
{
	self.imageView = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Properties



#pragma mark -
#pragma mark UIScrollViewDelegate
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	UIView* zoomView = nil;
	
	if ([self.innerScrollViewDelegate canZoom]) {
		zoomView = [self.subviews objectAtIndex:0];
	}
	return zoomView;
}


- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	[self.innerScrollViewDelegate didTouched:self];
}


@end
