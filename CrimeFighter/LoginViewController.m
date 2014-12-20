//
//  LoginViewController.m
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/24/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import "LoginViewController.h"
#import "AddCrimeViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "LoginPostObj.h"

@interface LoginViewController (){
    NSString *_userName;
    NSString *_userId;
}

@property (nonatomic,strong)NSString* userName;

@property (nonatomic,strong)NSString* userId;

@property (weak, nonatomic) IBOutlet UIButton *createCrimeButton;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong,nonatomic) id<FBGraphUser> fetchedUser;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Create a FBLoginView to log the user in with basic, email and likes permissions
    // You should ALWAYS ask for basic permissions (basic_info) when logging the user in
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
    
    // Set this loginUIViewController to be the loginView button's delegate
    loginView.delegate = self;
    
    // Align the button in the center horizontally
    loginView.frame = CGRectOffset(loginView.frame,
                                   (self.view.center.x - (loginView.frame.size.width / 2)),
                                   5);
    
    // Align the button in the center vertically
    loginView.center = self.view.center;
    
    // Add the button to the view
    [self.view addSubview:loginView];
    
    
    //self.loginView.readPermissions = @[@"basic_info", @"email", @"user_likes"];
    self.createCrimeButton.enabled=NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"toAddCrime"]){
        AddCrimeViewController *addCVC=segue.destinationViewController;
        addCVC.userID=self.userId;
    }
}



// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.id;
    self.nameLabel.text = user.name;
    self.fetchedUser=user;
    self.userName=user.name;
    self.userId=user.id;
    NSLog(@"%@",self.userName);
    self.createCrimeButton.enabled=YES;
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.statusLabel.text = @"You're logged in as";
    self.createCrimeButton.enabled=YES;
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
    self.statusLabel.text= @"You're not logged in!";
    self.createCrimeButton.enabled=NO;
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    self.createCrimeButton.enabled=NO;
}


- (IBAction)continueToPostCrime:(id)sender {
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:8080"]];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CrimeFighter.sqlite"];
    
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil  withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    manager.managedObjectStore = managedObjectStore;
    
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[LoginPostObj class]];
    [responseMapping addAttributeMappingsFromArray:@[@"user_name", @"user_FBID"]];
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    RKResponseDescriptor *createLoginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:@"/login" keyPath:nil statusCodes:statusCodes];
    
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    //RKEntityMapping *loginMapping=[RKEntityMapping mappingForEntityForName:@"Login" inManagedObjectStore:manager.managedObjectStore];
    [requestMapping addAttributeMappingsFromDictionary:@{
                                                         @"userFBID":@"user_FBID",
                                                         @"userName":@"user_name",
                                                         }];
    
    requestMapping = [requestMapping inverseMapping];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[LoginPostObj class] rootKeyPath:nil method:RKRequestMethodAny];
    
    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptor:createLoginResponseDescriptor];
    
    LoginPostObj *login = [LoginPostObj new];
    login.user_FBID=self.userId;
    login.user_name=self.userName;
    
    manager.requestSerializationMIMEType=RKMIMETypeJSON;
    
    
    RKManagedObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:login
                                                                                               method:RKRequestMethodPOST
                                                                                                 path:@"/CrimeReporter/logins"
                                                                                           parameters:nil];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // Success
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // Failure
    }];
    [manager enqueueObjectRequestOperation:operation];
    
}


@end
