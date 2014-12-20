//
//  AppDelegate.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/22/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
