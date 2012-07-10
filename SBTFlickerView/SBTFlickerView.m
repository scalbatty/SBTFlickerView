//
//  SBTFlickerView.m
//  SBTFlickerView
//
//  Created by Pascal Batty on 24/01/11.
//  Copyright 2011 Pascal Batty. All rights reserved.
//

#define kFDDequeueIndexNotFound -1
#define kFDShouldScrollIndexUndefined -1

#import "SBTFlickerView.h"
#import "SBTFlickerViewClip.h"

@interface SBTFlickerView()

- (void)calculateVisibleClips;
- (void)initLocalMembers;
- (SBTFlickerViewClip *)clipAtIndex:(NSUInteger)index;
- (void)recycleInvisibleClips;

@end


@implementation SBTFlickerView
@synthesize clipSpacing, clipSize, dataSource, delegate, clipsPerPage, allowsIncompletePages;

#pragma mark Initializers

- (id)initWithFrame:(CGRect)frame {
	if (!(self = [super initWithFrame:frame]))
		return nil;
	
	[self initLocalMembers];
	
	return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
	if (! (self = [super initWithCoder:aDecoder]))
        return nil;
	
	[self initLocalMembers];
	
	return self;
}

- (void)initLocalMembers {
	numberOfClipsIsDirty = YES;
	layoutIsDirty = YES;
	shouldScrollToIndex = kFDShouldScrollIndexUndefined;
	
	clipSpacing = 0;
	clipSize = [self frame].size;
	clipsPerPage = 1;
	allowsIncompletePages = NO;
	
	
	scrollView = [[UIScrollView alloc] initWithFrame:[self frame]];
	[scrollView setScrollEnabled:YES];
	[scrollView setShowsHorizontalScrollIndicator:NO];
	[scrollView setShowsVerticalScrollIndicator:NO];
	[scrollView setClipsToBounds:NO];
	[scrollView setBackgroundColor:[UIColor clearColor]];
	[scrollView setDelegate:self];
    
    visibleClips = [[NSMutableSet alloc] init];
    recycledClips = [[NSMutableSet alloc] init];
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
	[super addSubview:scrollView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == scrollView &&
        keyPath == @"contentOffset") {
        [self setNeedsLayout];
    }
}

#pragma mark Inner mechanisms

- (void)calculateVisibleClips {
	CGFloat horizontalOffset = [scrollView contentOffset].x;
	CGFloat scrollViewOrigin = [scrollView frame].origin.x;
	CGFloat clipFrameWidth = clipSize.width + clipSpacing;
	CGFloat pageSize = clipFrameWidth * clipsPerPage;
	
	CGFloat invisibleLeftDistance = horizontalOffset - scrollViewOrigin;
	CGFloat farRightOffset = horizontalOffset + scrollViewOrigin + pageSize;
	
	firstVisibleClipIndex = MAX(0, invisibleLeftDistance / clipFrameWidth);
	if (firstVisibleClipIndex >= numberOfClips) firstVisibleClipIndex = numberOfClips - 1;
	
	lastVisibleClipIndex = MAX(0, farRightOffset / clipFrameWidth);
	if (lastVisibleClipIndex >= numberOfClips) lastVisibleClipIndex = numberOfClips - 1;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	if (dataSource) {
	
		CGFloat clipFrameWidth = clipSize.width + clipSpacing;
		CGFloat pageSize = clipFrameWidth * clipsPerPage;
		CGFloat flickerViewWidth = [self frame].size.width;
		CGFloat flickerViewHeight = [self frame].size.height;
		CGRect scrollViewFrame = CGRectMake((flickerViewWidth - pageSize)/2, 0, pageSize, flickerViewHeight);
		
		if (!CGRectEqualToRect(scrollViewFrame, [scrollView frame])) {
			[scrollView setFrame:scrollViewFrame];
		}		
		
		if (numberOfClipsIsDirty) {
			numberOfClips = [dataSource numberOfClipsInFlickerView:self];
			numberOfClipsIsDirty = NO;

			for (UIView *subView in [scrollView subviews]) {
				[subView removeFromSuperview];
			}
			
            [visibleClips removeAllObjects];
            [recycledClips removeAllObjects];
            
			if (!allowsIncompletePages) {
				int pageCount = ceil((double)numberOfClips/(double)clipsPerPage);
				[scrollView setContentSize:CGSizeMake((pageSize) * pageCount, flickerViewHeight)];
			}
			else {
				CGFloat totalWidth = numberOfClips * clipFrameWidth;
				[scrollView setContentSize:CGSizeMake(totalWidth, flickerViewHeight)];
			}
			if (shouldScrollToIndex != kFDShouldScrollIndexUndefined) {
				layoutIsDirty = NO;
				[self scrollToPage:shouldScrollToIndex animated:NO];
				shouldScrollToIndex = kFDShouldScrollIndexUndefined;
			}
		}
		
		if (numberOfClips > 0) 
		{
			[self calculateVisibleClips];
            [self recycleInvisibleClips];
        
			for (uint i = firstVisibleClipIndex; i <= lastVisibleClipIndex; i++) {
				if (![self clipAtIndex:i]) {
					
					SBTFlickerViewClip *newClip = [dataSource flickerView:self clipForIndex:i];

					[newClip addTarget:self action:@selector(tappedClip:) forControlEvents:UIControlEventTouchUpInside];
                    [newClip setIndex:(uint)i];
                    [visibleClips addObject:newClip];
					
					CGFloat horizontalPosition = clipSpacing / 2.0 + clipFrameWidth * i;
					[newClip setFrame:CGRectMake(horizontalPosition, (flickerViewHeight - clipSize.height)/2,
															   clipSize.width, clipSize.height)];
					[scrollView addSubview:(UIView *)newClip];
				}
			}
		}
	}
}

// This method override allows the FlickerView to intercept Touch Events inside
// itself and send them to the ScrollView.
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self) {
        return scrollView;         
	}
    return child;
}

- (SBTFlickerViewClip *)clipAtIndex:(NSUInteger)index {
    for (SBTFlickerViewClip *clip in visibleClips) {
        if ([clip index] == index) {
            return clip;
        }
    }
    return nil;
}

- (void)recycleInvisibleClips {
    for (SBTFlickerViewClip *clip in visibleClips) {
        if ([clip index] < firstVisibleClipIndex || [clip index] > lastVisibleClipIndex) {
            [recycledClips addObject:clip];
        }
    }
    [visibleClips minusSet:recycledClips];
}

#pragma mark Behaviour Methods

- (SBTFlickerViewClip *)dequeueReusableClipWithIdentifier:(NSString *)identifier {
    NSPredicate *reuseIdentifierPredicate = [NSPredicate predicateWithFormat:@"reuseIdentifier == %@", identifier];
    NSSet *identifiedRecycledClips = [recycledClips filteredSetUsingPredicate:reuseIdentifierPredicate];
	SBTFlickerViewClip *clip = [identifiedRecycledClips anyObject];
    if (clip) {
        [[clip retain] autorelease];
        [recycledClips removeObject:clip];
    }
    return clip;
}

- (void)scrollToPage:(NSUInteger)index animated:(BOOL)animated {
	if (layoutIsDirty) {
		shouldScrollToIndex = index;
	}
	else {
		if (index < numberOfClips) {
			CGFloat pageOffset = [scrollView frame].size.width * index;
			[scrollView setContentOffset:CGPointMake(pageOffset, 0) animated:animated];
			if ([delegate respondsToSelector:@selector(flickerView:didScrollToPageIndex:)]) {
				[delegate flickerView:self didScrollToPageIndex:index];
			}
		}
	}
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
	[scrollView setContentOffset:contentOffset animated:animated];
}

- (void)reloadData {
	layoutIsDirty = YES;
	numberOfClipsIsDirty = YES;
	[self scrollToPage:0 animated:NO];
	[self setNeedsLayout];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
	if ([scrollView frame].size.width > 0) {
		int page = [scrollView contentOffset].x / [scrollView frame].size.width;
		if ([delegate respondsToSelector:@selector(flickerView:didScrollToPageIndex:)]) {
			[delegate flickerView:self didScrollToPageIndex:page];
		}
	}
}

- (void)tappedClip:(id)sender {
	if ([delegate respondsToSelector:@selector(flickerView:didSelectClipAtIndex:)]) {
		SBTFlickerViewClip *tappedClip = (SBTFlickerViewClip *)sender;
		int tappedClipIndex = [tappedClip index];

		[delegate flickerView:self didSelectClipAtIndex:tappedClipIndex];
	}	
}

#pragma mark Accessor implementation

- (BOOL)isPagingEnabled {
	if (scrollView) {
		return [scrollView isPagingEnabled];
	}
	else return NO;
}


- (void)setPagingEnabled:(BOOL)enable {
	if (scrollView) {
		[scrollView setPagingEnabled:enable];
	}
}

- (BOOL)isScrollEnabled {
	if (scrollView) {
		return [scrollView isScrollEnabled];
	}
	else return NO;
}


- (void)setScrollEnabled:(BOOL)enable {
	[scrollView setScrollEnabled:enable];
}

- (float)decelerationRate {
	if (scrollView) {
		return [scrollView decelerationRate];
	}
	return UIScrollViewDecelerationRateNormal;
}

- (void)setDecelerationRate:(float)decelerationRate {
	[scrollView setDecelerationRate:decelerationRate];
}

- (CGPoint)contentOffset {
	if (scrollView) {
		return [scrollView contentOffset];
	}
	return CGPointZero;
}

- (void)setContentOffset:(CGPoint)contentOffset {
	[scrollView setContentOffset:contentOffset];
}

- (CGSize)contentSize {
	if (scrollView) {
		return [scrollView contentSize];
	}
	return CGSizeZero;
}

#pragma mark Memory

- (void)dealloc {
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
	[scrollView release];
	[visibleClips release];
    [recycledClips release];
	
	[super dealloc];
}

@end
