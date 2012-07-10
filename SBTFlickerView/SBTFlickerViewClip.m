//
//  FDCarouselViewClip.m
//  SBTFlickerView
//
//  Created by Pascal Batty on 24/01/11.
//  Copyright 2011 Pascal Batty. All rights reserved.
//

#import "SBTFlickerViewClip.h"


@implementation SBTFlickerViewClip
@synthesize reuseIdentifier, index;

- (id) initWithContentView:(UIView *)view 
		andReuseIdentifier:(NSString *)identifier {
	self = [super init];
	if (self) {
		if (view) {
			[self setFrame:[view bounds]];
			[self setContentView:view];
		}
		[self setReuseIdentifier:identifier];
	}
	return self;
}

- (UIView *)contentView {
	if ([self.subviews count] > 0) {
		return [self.subviews objectAtIndex:0];
	}
	return nil;
}

- (void)setContentView:(UIView *)contentView {
	if ([self.subviews count] > 0) {
		[(UIView *)[self.subviews objectAtIndex:0] removeFromSuperview];
	}
	[self addSubview:contentView];
}

- (id) initWithContentView:(UIView *)view {
	[self initWithContentView:view andReuseIdentifier:nil];
	return self;
}

- (id)initWithReuseIdentifier:(NSString *)identifier {
	[self initWithContentView:nil andReuseIdentifier:identifier];
	return self;
}

- (void) dealloc
{
	[reuseIdentifier release];
	[super dealloc];
}


@end
