//
//  AddCrimeViewController.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/24/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddCrimeViewController : UIViewController<CLLocationManagerDelegate>

@property NSString *userID;

@property (weak, nonatomic) IBOutlet UITextField *crimeDescription;

@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UITextField *crimeType;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFBUser:(NSString*)user;

@property (nonatomic,retain) IBOutlet MKMapView *mapView;

-(IBAction)setMap:(id)sender;

@property double latitude,longitude;

@end
