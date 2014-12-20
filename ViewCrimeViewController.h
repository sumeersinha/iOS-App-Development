//
//  ViewCrimeViewController.h
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/25/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface ViewCrimeViewController : UIViewController <CLLocationManagerDelegate>{
    double latitude;
    double longitude;
}
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property double latitude;
@property double longitude;
@end
