//
//  ChargingStation.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/12/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "ChargingStation.h"

// API Key for NREL
#define kApiKeyNrel "sQUMD8G5IKWZtOOQeYatEHBFJR6YEf8DFRj9mJhe"

@implementation ChargingStation

- (instancetype)initWithChargingStationPFObject:(PFObject *)chargingStationObject
{
    self = [super init];
    if (self) {
        self.latitude = [chargingStationObject[@"latitude"] doubleValue];
        self.longitude = [chargingStationObject[@"longitude"] doubleValue];
        self.stationName = chargingStationObject[@"stationName"];
        self.stationAddress = chargingStationObject[@"stationAddress"];
        self.stationPhone = chargingStationObject[@"stationPhoneNumber"];
        self.city = chargingStationObject[@"city"];
        self.state = chargingStationObject[@"state"];
        self.level1Charge = chargingStationObject[@"ev_level1_evse_num"];
        self.level2Charge = chargingStationObject[@"ev_level2_evse_num"];
        self.evDCFastNum = chargingStationObject[@"ev_dc_fast_num"];
        self.evOtherEvse = chargingStationObject[@"ev_other_evse"];
        self.groupAccessCode = chargingStationObject[@"groups_with_access_code"];
        self.ownerTypeCode = chargingStationObject[@"owner_type_code"];
        self.otherCharge = chargingStationObject[@"ev_other_evse"];
        self.zipCode = [chargingStationObject[@"zipCode"] doubleValue];
        self.nrel_id = chargingStationObject[@"nrel_id"];
        self.object_id = chargingStationObject.objectId;
    }
    return self;
}

+ (void)addAPIDatatoParse
{
    NSString *jsonAddress = [NSString stringWithFormat:@"https://developer.nrel.gov/api/alt-fuel-stations/v1.json?api_key=%s&fuel_type=ELEC&state=CA&limit=200", kApiKeyNrel];
    NSURL *url = [NSURL URLWithString:jsonAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         NSArray *stationsArray = [resultsDictionary objectForKey:@"fuel_stations"];

         for (NSDictionary *chargingStationDictionary in stationsArray)
         {
             PFObject *chargingStationInfo = [PFObject objectWithClassName:@"Stations"];
             chargingStationInfo[@"stationName"] = chargingStationDictionary[@"station_name"];
             chargingStationInfo[@"latitude"] = chargingStationDictionary[@"latitude"];
             chargingStationInfo[@"longitude"] = chargingStationDictionary[@"longitude"];
             chargingStationInfo[@"stationAddress"] = chargingStationDictionary[@"street_address"];
             chargingStationInfo[@"zipCode"] = chargingStationDictionary[@"zip"];
             chargingStationInfo[@"state"] = chargingStationDictionary[@"state"];
             chargingStationInfo[@"city"] = chargingStationDictionary[@"city"];
             chargingStationInfo[@"country"] = @"United States";
             chargingStationInfo[@"stationPhoneNumber"] = chargingStationDictionary[@"station_phone"];
             chargingStationInfo[@"groups_with_access_code"] = chargingStationDictionary[@"groups_with_access_code"];
             chargingStationInfo[@"owner_type_code"] = chargingStationDictionary[@"owner_type_code"];
             chargingStationInfo[@"ev_connector_types"] = chargingStationDictionary[@"ev_connector_types"];
             chargingStationInfo[@"ev_level1_evse_num"] = chargingStationDictionary[@"ev_level1_evse_num"];
             chargingStationInfo[@"ev_level2_evse_num"] = chargingStationDictionary[@"ev_level2_evse_num"];
             chargingStationInfo[@"ev_dc_fast_num"] = chargingStationDictionary[@"ev_dc_fast_num"];
             chargingStationInfo[@"ev_other_evse"] = chargingStationDictionary[@"ev_other_evse"];
             chargingStationInfo[@"nrel_id"] = chargingStationDictionary[@"id"];

             [chargingStationInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (!error) {
                     NSLog(@"Completed Saving to Parse");
                 }
                 else NSLog(@"%@", error);
             }];
         }
     }];
}

/**
 *  Returns a Charging Station Object for a nrel_id
 *
 *  @param nrel_id    The id for a station from the nrel api (https://developer.nrel.gov)
 *  @param completion
 */
+ (void)getChargingStationInfoForID:(NSNumber *)nrel_id andCompletion:(void(^)(ChargingStation *chargingStationInfo))completion
{
    NSString *jsonAddress = [NSString stringWithFormat:@"https://developer.nrel.gov/api/alt-fuel-stations/v1.json?api_key=%s&fuel_type=ELEC&id=%d&limit=1", kApiKeyNrel, [nrel_id intValue]];
    NSURL *url = [NSURL URLWithString:jsonAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         NSArray *stationsArray = [resultsDictionary objectForKey:@"fuel_stations"];

         for (NSDictionary *chargingStationDictionary in stationsArray)
         {
             ChargingStation *chargingStation = [ChargingStation new];
             chargingStation.latitude = [chargingStationDictionary[@"latitude"] doubleValue];
             chargingStation.longitude = [chargingStationDictionary[@"longitude"] doubleValue];
             chargingStation.stationName = chargingStationDictionary[@"station_name"];
             chargingStation.stationAddress = chargingStationDictionary[@"street_address"];
             chargingStation.stationPhone = chargingStationDictionary[@"station_phone"];
             chargingStation.city = chargingStationDictionary[@"city"];
             chargingStation.state = chargingStationDictionary[@"state"];
             chargingStation.level1Charge = chargingStationDictionary[@"ev_level1_evse_num"];
             chargingStation.level2Charge = chargingStationDictionary[@"ev_level2_evse_num"];
             chargingStation.evDCFastNum = chargingStationDictionary[@"ev_dc_fast_num"];
             chargingStation.evOtherEvse = chargingStationDictionary[@"ev_other_evse"];
             chargingStation.groupAccessCode = chargingStationDictionary[@"groups_with_access_code"];
             chargingStation.ownerTypeCode = chargingStationDictionary[@"owner_type_code"];
             chargingStation.otherCharge = chargingStationDictionary[@"ev_other_evse"];
             chargingStation.zipCode = [chargingStationDictionary[@"zip"] doubleValue];
             chargingStation.nrel_id = chargingStationDictionary[@"id"];

             completion(chargingStation);
         }
     }];
}

// Saves API Data to Parse and returns a PFObject
+ (void)saveAPIDataToParse:(NSNumber *)nrel_id andCompletion:(void(^)(PFObject *chargingStationObject))completion
{
    NSString *jsonAddress = [NSString stringWithFormat:@"https://developer.nrel.gov/api/alt-fuel-stations/v1/%lu.json?api_key=%s", [nrel_id longValue], kApiKeyNrel];
    NSURL *url = [NSURL URLWithString:jsonAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data) {
             NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSDictionary *chargingStationDictionary = [resultsDictionary objectForKey:@"alt_fuel_station"];

             PFObject *chargingStationInfo = [PFObject objectWithClassName:@"Stations"];
             chargingStationInfo[@"stationName"] = chargingStationDictionary[@"station_name"];
             chargingStationInfo[@"latitude"] = chargingStationDictionary[@"latitude"];
             chargingStationInfo[@"longitude"] = chargingStationDictionary[@"longitude"];
             chargingStationInfo[@"stationAddress"] = chargingStationDictionary[@"street_address"];
             chargingStationInfo[@"zipCode"] = chargingStationDictionary[@"zip"];
             chargingStationInfo[@"state"] = chargingStationDictionary[@"state"];
             chargingStationInfo[@"city"] = chargingStationDictionary[@"city"];
             chargingStationInfo[@"country"] = @"United States";
             chargingStationInfo[@"stationPhoneNumber"] = chargingStationDictionary[@"station_phone"];
             chargingStationInfo[@"groups_with_access_code"] = chargingStationDictionary[@"groups_with_access_code"];
             chargingStationInfo[@"owner_type_code"] = chargingStationDictionary[@"owner_type_code"];
             chargingStationInfo[@"ev_connector_types"] = chargingStationDictionary[@"ev_connector_types"];
             chargingStationInfo[@"ev_level1_evse_num"] = chargingStationDictionary[@"ev_level1_evse_num"];
             chargingStationInfo[@"ev_level2_evse_num"] = chargingStationDictionary[@"ev_level2_evse_num"];
             chargingStationInfo[@"ev_dc_fast_num"] = chargingStationDictionary[@"ev_dc_fast_num"];
             chargingStationInfo[@"ev_other_evse"] = chargingStationDictionary[@"ev_other_evse"];
             chargingStationInfo[@"nrel_id"] = chargingStationDictionary[@"id"];

             [chargingStationInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (!error) {
                     completion(chargingStationInfo);
                     NSLog(@"Completed Saving to Parse");
                 }
                 else NSLog(@"%@", error);
             }];
         }
         else
         {
             NSLog(@"Station with id %lu could not be saved to parse", [nrel_id longValue]);
         }

     }];
}


@end
