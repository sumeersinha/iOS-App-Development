//
//  CrimePostObj.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/25/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrimePostObj : NSObject

@property (nonatomic, retain) NSString * crime_type;
@property (nonatomic, retain) NSString * id_user;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * crime_desc;
@property double latitude;
@property double longitude;

@end
