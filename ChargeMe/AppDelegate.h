//
//  AppDelegate.h
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/9/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import <SpeechKit/SpeechKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) CLLocationManager *customLocationManager;
@property (strong, nonatomic) CLLocation *currentUserLocation;

- (void)updateCurrentLocation;
- (void)stopUpdatingCurrentLocation;
- (void)setupSpeechKitConnection;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

