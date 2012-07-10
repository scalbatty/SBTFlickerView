//
//  SBTMainViewController.h
//  SBTFlickerView
//
//  Created by Pascal Batty on 10/07/12.
//  Copyright (c) 2012 Pascal Batty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTFlickerView.h"

@interface SBTMainViewController : UIViewController <SBTFlickerViewDelegate, SBTFlickerViewDataSource>
@property (retain, nonatomic) IBOutlet SBTFlickerView *flickerView;

@end
