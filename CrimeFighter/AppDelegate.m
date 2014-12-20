//
//  AppDelegate.m
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/22/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import "AppDelegate.h"
#import "Login.h"
# import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    RKObjectManager* objectManager=[RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:8080/"]];
//    self.objectStore=[[RKManagedObjectStore alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
//    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CrimeFighter.sqlite"];
//    [self.objectStore addSQLitePersistentStoreAtPath:path
//                              fromSeedDatabaseAtPath:nil
//                                   withConfiguration:nil
//                                             options:@{
//                                                       NSInferMappingModelAutomaticallyOption: @YES,
//                                                       NSMigratePersistentStoresAutomaticallyOption: @YES
//                                                       }
//                                               error:nil];
//    [self.objectStore createManagedObjectContexts];
//    
//    objectManager.managedObjectStore=self.objectStore;
//    objectManager.requestSerializationMIMEType=RKMIMETypeJSON;
//    
//    RKEntityMapping* crimeMapping=[RKEntityMapping mappingForEntityForName:@"Crime"
//                        inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
//    
//    crimeMapping.identificationAttributes = @[@"id"] ;
//    
//    [crimeMapping addAttributeMappingsFromDictionary:@{
//                                                  @"id": @"id",
//                                                  @"crime_date": @"crime_date",
//                                                  @"crime_type":@"crime_type",
//                                                  @"id_user":@"id_user",
//                                                  @"location":@"location",
//                                                  @"version":@"version"
//                                                  }];
//    
//    RKEntityMapping* loginMapping=[RKEntityMapping mappingForEntityForName:@"Login"
//                                                      inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
//    
//    loginMapping.identificationAttributes = @[@"id_user"] ;
//    
//    /*
//     
//     @property (nonatomic, retain) NSNumber * id_user;
//     @property (nonatomic, retain) NSString * password;
//     @property (nonatomic, retain) NSString * user_name;
//     @property (nonatomic, retain) NSNumber * version;
//     */
//    
//    [loginMapping addAttributeMappingsFromDictionary:@{
//                                                       @"id_user": @"id_user",
//                                                       @"password": @"password",
//                                                       @"user_name":@"user_name",
//                                                       @"version":@"version"
//                                                       }];

    
    [FBLoginView class];
    [FBProfilePictureView class];
    return YES;
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupRestKit{
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://api.parse.com/1/"]];
    
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-REST-API-Key" value:@"your key"];
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-Application-Id" value:@"your key"];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    /*
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                    pathPattern:nil
                                                                                        keyPath:@"error"
                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    [manager addResponseDescriptorsFromArray:@[errorDescriptor]];
    */
    
    RKEntityMapping *loginMapping = [RKEntityMapping mappingForEntityForName:@"Login" inManagedObjectStore:manager.managedObjectStore];
    loginMapping.identificationAttributes = @[ @"id_user" ];
    [loginMapping addAttributeMappingsFromDictionary:@{
                                                       @"idUser": @"id_user",
                                                       @"password":@"password",
                                                       @"userName":@"user_name",
                                                       @"version":@"version"
                                                       }];
    
    // Register our mappings with the provider
    
    [manager addResponseDescriptorsFromArray:@[
                                               [RKResponseDescriptor responseDescriptorWithMapping:loginMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/CrimeReporter/logins"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]]
                                               ]];
    
    /**
     Complete Core Data stack initialization
     */
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CrimeFighter.sqlite"];
    
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil  withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
}


@end
