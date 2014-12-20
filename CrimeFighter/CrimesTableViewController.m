//
//  CrimesTableViewController.m
//  CrimeFighter
//
//  Created by Sumeer Sinha on 4/22/14.
//  Copyright (c) 2014 Sumeer Sinha. All rights reserved.
//

#import "CrimesTableViewController.h"
#import "Crime.h"
#import "Login.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "ViewCrimeViewController.h"

@interface CrimesTableViewController ()

@property(strong,nonatomic) NSArray *logins;
@property(strong,nonatomic) NSArray *crimes;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation CrimesTableViewController

- (void)setupRestKit{
     RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:8080"]];
    
    //[[manager HTTPClient] setDefaultHeader:@"REST-API-Key" value:@"your key"];
    //[[manager HTTPClient] setDefaultHeader:@"Application-Id" value:@"your key"];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
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
    
    RKEntityMapping *loginMapping = [RKEntityMapping mappingForEntityForName:@"Login" inManagedObjectStore:manager.managedObjectStore];
    loginMapping.identificationAttributes = @[ @"id_user" ];
    [loginMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"id_user",
                                                       @"password":@"password",
                                                       @"userName":@"user_name",
                                                       @"version":@"version"
                                                       }];
    
    RKEntityMapping *crimesMapping = [RKEntityMapping mappingForEntityForName:@"Crime" inManagedObjectStore:manager.managedObjectStore];
    crimesMapping.identificationAttributes = @[ @"crime_id" ];
    [crimesMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"crime_id",
                                                       @"crimeType":@"crime_type",
                                                       @"idUser":@"id_user",
                                                       @"location":@"location",
                                                       @"version":@"version",
                                                       @"crimeDescription":@"crime_desc",
                                                       @"latitude":@"latitude",
                                                       @"longitude":@"longitude"
                                                       }];
    
    // Register our mappings with the provider
    [manager addResponseDescriptorsFromArray:@[
                                               [RKResponseDescriptor responseDescriptorWithMapping:loginMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/CrimeReporter/logins"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]]
                                               ]];
    [manager addResponseDescriptorsFromArray:@[
                                               [RKResponseDescriptor responseDescriptorWithMapping:crimesMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/CrimeReporter/crimes"
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
    
    
    //Configure to delete orphaned objects
    [[RKObjectManager sharedManager] addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/CrimeReporter/crimes"];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        NSString *crimeId;
        if (match) {
            crimeId = [argsDict objectForKey:@"crime_id"];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Crime"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"crime_id != %@", @([crimeId integerValue])];
            fetchRequest.predicate = predicate;
            fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"crime_id" ascending:YES] ];
            return fetchRequest;
        }
        
        return nil;
    }];
    
}


- (void)loadLogins
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/CrimeReporter/logins"
                                    parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSLog(@"TestLogins");
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no login?': %@", error);
                                              }];
}

- (void)loadCrimes
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/CrimeReporter/crimes"
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSLog(@"TestCrimes");
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no login?': %@", error);
                                              }];
}
/*
//Fetch Logins
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Login class])];
        
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id_user" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:@"id_user" cacheName:@"Login"];
        self.fetchedResultsController.delegate = self;
        
        NSError *error;
        
        [self.fetchedResultsController performFetch:&error];
        
        NSLog(@"%@",[self.fetchedResultsController fetchedObjects]);
        
        NSAssert(!error, @"Error performing fetch request: %@", error);
        
    }
    
    return _fetchedResultsController;
    
}*/

//Fetch Crimes
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Crime class])];
        
        
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:@"location" cacheName:@"Crime"];
        self.fetchedResultsController.delegate = self;
        
        NSError *error;
        
        [self.fetchedResultsController performFetch:&error];
        
        NSLog(@"%@",[self.fetchedResultsController fetchedObjects]);
        
        NSAssert(!error, @"Error performing fetch request: %@", error);
        
    }
    
    return _fetchedResultsController;
    
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupRestKit];
    //[self loadLogins];
    [self loadCrimes];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return [self.fetchedResultsController sectionIndexTitles];
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo name];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"crimeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Crime *crime=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=crime.crime_type;
    cell.detailTextLabel.text=crime.location;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView reloadData];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"toCrimeDetail"]){
        
        NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
        
        Crime *selectedCrime=[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        ViewCrimeViewController *toVC=segue.destinationViewController;
        UILabel *crimeType=(UILabel*) [toVC.view viewWithTag:1];
        UILabel *crimeDesc=(UILabel*) [toVC.view viewWithTag:2];
        UILabel *crimeLocation=(UILabel*) [toVC.view viewWithTag:3];
        
        if(crimeType){
            crimeType.text=selectedCrime.crime_type;
            crimeDesc.text=selectedCrime.crime_desc;
            crimeLocation.text=selectedCrime.location;
            toVC.latitude=[selectedCrime.latitude doubleValue];
            toVC.longitude=[selectedCrime.longitude doubleValue];
        }
    }
    
}


- (IBAction)refresh:(id)sender {
    [self viewDidLoad];
}
@end
