//
//  SBTFlickerView.h
//  SBTFlickerView
//
//  Created by Pascal Batty on 24/01/11.
//  Copyright 2011 Pascal Batty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBTFlickerView;
@class SBTFlickerViewClip;

@protocol SBTFlickerViewDataSource <NSObject>

- (NSInteger)numberOfClipsInFlickerView:(SBTFlickerView *)flickerView;
- (SBTFlickerViewClip *)flickerView:(SBTFlickerView *)flickerView clipForIndex:(NSInteger)index;

@end

@protocol SBTFlickerViewDelegate <NSObject>
@optional
- (void)flickerView:(SBTFlickerView *)flickerView didScrollToPageIndex:(NSInteger)pageIndex;
- (void)flickerView:(SBTFlickerView *)flickerView didSelectClipAtIndex:(NSInteger)clipIndex;

@end


@interface SBTFlickerView : UIView <UIScrollViewDelegate> {
	
	id<SBTFlickerViewDataSource>	dataSource;
	id<SBTFlickerViewDelegate>		delegate;
	
	UIScrollView	*scrollView;

	CGSize			clipSize;
	CGFloat			clipSpacing;	
	NSUInteger		firstVisibleClipIndex;
	NSUInteger		lastVisibleClipIndex;
	NSUInteger		numberOfClips;
	NSInteger		shouldScrollToIndex;
	NSInteger		clipsPerPage;
	BOOL			numberOfClipsIsDirty;
	BOOL			layoutIsDirty;
    
    NSMutableSet    *recycledClips;
    NSMutableSet    *visibleClips;
}

@property (nonatomic) CGSize clipSize;
@property (nonatomic) CGFloat clipSpacing;
@property (nonatomic, assign) id<SBTFlickerViewDataSource> dataSource;
@property (nonatomic, assign) id<SBTFlickerViewDelegate> delegate;
@property (nonatomic, assign) NSInteger clipsPerPage;

@property (nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign) float decelerationRate;
@property (nonatomic, assign) BOOL allowsIncompletePages;
@property (nonatomic, assign) CGPoint contentOffset;

- (void)scrollToPage:(NSUInteger)index animated:(BOOL)animated;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

- (CGSize)contentSize;

- (SBTFlickerViewClip *)dequeueReusableClipWithIdentifier:(NSString *)identifier;
- (void)reloadData;

@end
