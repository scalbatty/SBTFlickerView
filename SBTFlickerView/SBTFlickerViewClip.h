//
//  FDCarouselViewClip.h
//  SBTFlickerView
//
//  Created by Pascal Batty on 24/01/11.
//  Copyright 2011 Pascal Batty. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SBTFlickerViewClip : UIControl {
	NSString	*reuseIdentifier;
}

@property (nonatomic, retain) NSString *reuseIdentifier;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) UIView *contentView;

- (id)initWithContentView:(UIView *)view 
		andReuseIdentifier:(NSString *)identifier;

- (id)initWithContentView:(UIView *)view;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end
