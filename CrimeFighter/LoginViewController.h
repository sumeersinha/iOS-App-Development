//
//  LoginViewController.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/24/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController<FBLoginViewDelegate>
- (IBAction)continueToPostCrime:(id)sender;

@end
