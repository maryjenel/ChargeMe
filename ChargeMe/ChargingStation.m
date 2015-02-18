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

+ (void)addAPIDatatoParse
{
    NSString *jsonAddress = [NSString stringWithFormat:@"https://developer.nrel.gov/api/alt-fuel-stations/v1.json?api_key=%s&fuel_type=ELEC&state=CA&limit=5", kApiKeyNrel];
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

             [chargingStationInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (!error) {
                     NSLog(@"Completed Saving to Parse");
                 }
                 else NSLog(@"%@", error);
             }];
         }
     }];
}

@end
