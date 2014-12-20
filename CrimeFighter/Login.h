//
//  Login.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/25/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Login : NSManagedObject

@property (nonatomic, retain) NSString * id_user;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * user_FBID;

@end
