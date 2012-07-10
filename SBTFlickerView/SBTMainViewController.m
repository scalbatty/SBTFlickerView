//
//  SBTMainViewController.m
//  SBTFlickerView
//
//  Created by Pascal Batty on 10/07/12.
//  Copyright (c) 2012 Pascal Batty. All rights reserved.
//

#import "SBTMainViewController.h"
#import "SBTFlickerViewClip.h"

@interface SBTMainViewController ()

@end

@implementation SBTMainViewController
@synthesize flickerView = _flickerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	_flickerView.clipSize = CGSizeMake(100.0, 150.0);
	_flickerView.clipSpacing = 5.0;
	_flickerView.clipsPerPage = 3;
	_flickerView.dataSource = self;
	_flickerView.delegate = self;
	_flickerView.pagingEnabled = YES;
}

- (void)viewDidUnload
{
    [self setFlickerView:nil];
    [super viewDidUnload];
}


- (void)dealloc {
    [_flickerView release];
    [super dealloc];
}

#pragma mark - Flicker view Data source 

- (NSInteger)numberOfClipsInFlickerView:(SBTFlickerView *)flickerView {
	return 100;
}

- (SBTFlickerViewClip *)flickerView:(SBTFlickerView *)flickerView clipForIndex:(NSInteger)index {
	static NSString *identifier = @"identifier";
	
	SBTFlickerViewClip *clip = [flickerView dequeueReusableClipWithIdentifier:identifier];
	if (!clip) {
		UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 150)];
		numberLabel.backgroundColor = [UIColor whiteColor];
		numberLabel.font = [UIFont boldSystemFontOfSize:24.0];
		numberLabel.textAlignment = UITextAlignmentCenter;
		clip = [[SBTFlickerViewClip alloc] initWithContentView:numberLabel andReuseIdentifier:identifier];
		[numberLabel release];
	}
	
	((UILabel *)(clip.contentView)).text = [NSString stringWithFormat:@"%i", index];
	return clip;
}

#pragma mark - Flicker view Delegate

- (void)flickerView:(SBTFlickerView *)flickerView didSelectClipAtIndex:(NSInteger)clipIndex {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tapped clip" 
													message:[NSString stringWithFormat:@"Index: %i", clipIndex]
												   delegate:nil 
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

@end
