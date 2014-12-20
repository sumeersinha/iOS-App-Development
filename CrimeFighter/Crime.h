//
//  Crime.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/25/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Crime : NSManagedObject

@property (nonatomic, retain) NSNumber * crime_id;
@property (nonatomic, retain) NSString * crime_type;
@property (nonatomic, retain) NSNumber * id_user;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * crime_desc;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
