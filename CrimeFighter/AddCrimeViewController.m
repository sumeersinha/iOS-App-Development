//
//  AddCrimeViewController.m
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/24/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import "AddCrimeViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "CrimePostObj.h"

@interface AddCrimeViewController (){
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *area;
}

@end

@implementation AddCrimeViewController

@synthesize userID,mapView,crimeDescription,crimeType,address,latitude,longitude;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFBUser:(NSString*)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.userID=user;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",self.userID);
    self.mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)setMap:(id)sender{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            mapView.mapType=MKMapTypeStandard;
            mapView.showsUserLocation=YES;
            break;
        case 1:
            mapView.mapType=MKMapTypeSatellite;
            mapView.showsUserLocation=YES;
            break;
        case 2:
            mapView.mapType=MKMapTypeHybrid;
            mapView.showsUserLocation=YES;
            break;
        default:
            break;
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    [self.mapView removeAnnotations:mapView.annotations];
    
    if (currentLocation != nil) {
        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
        
        longitude=currentLocation.coordinate.longitude;
        latitude=currentLocation.coordinate.latitude;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = currentLocation.coordinate;
    point.title = @"Where am I?";
    point.subtitle = @"I'm here!!!";
    
     [self.mapView addAnnotation:point];
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            address.text = [NSString stringWithFormat:@"%@ %@\n%@ %@",
                            placemark.postalCode, placemark.locality,
                            placemark.administrativeArea,
                            placemark.country];
            area=placemark.administrativeArea;
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *crimeTypeCheck= self.crimeType.text;
    NSString *crimeDesc= self.crimeDescription.text;
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:8080"]];
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    /*
     crimeDescription: "fghj"
     crimeType: "theft"
     id: 1
     idUser: 111
     latitude: 22.22
     location: "boston"
     longitude: 11.22
     version: 0
     */
    [requestMapping addAttributeMappingsFromDictionary:@{
                                                         @"crimeDescription":@"crime_desc",
                                                         @"crimeType":@"crime_type",
                                                         @"idUser":@"id_user",
                                                         @"location":@"location",
                                                         @"latitude":@"latitude",
                                                         @"longitude":@"longitude"
                                                         }];
    
    requestMapping = [requestMapping inverseMapping];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[CrimePostObj class] rootKeyPath:nil method:RKRequestMethodAny];
    
    [manager addRequestDescriptor:requestDescriptor];
    
    CrimePostObj *crime = [CrimePostObj new];
    crime.crime_desc=crimeDesc;
    crime.crime_type=crimeTypeCheck;
    crime.location=area;
    crime.id_user=self.userID;
    crime.longitude=longitude;
    crime.latitude=latitude;
    
    manager.requestSerializationMIMEType=RKMIMETypeJSON;
    
    
    RKManagedObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:crime
                                                                                               method:RKRequestMethodPOST
                                                                                                 path:@"/CrimeReporter/crimes"
                                                                                           parameters:nil];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // Success
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // Failure
    }];
    [manager enqueueObjectRequestOperation:operation];
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}


@end
