//
//  ChargingStation.h
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/12/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h> 
#import <Parse/Parse.h>

@interface ChargingStation : NSObject

@property double longitude;
@property double latitude;
@property double stationID;
@property NSString *stationAddress;	
@property NSString *stationName;
@property NSString *stationPhone;
@property NSString *city;
@property NSString *state;
@property double zipCode;
@property NSString *level1Charge;
@property NSString *level2Charge;
@property NSString *groupAccessCode;
@property NSString *ownerTypeCode;
@property NSString *evConnectorTypes;
@property NSString *evDCFastNum;
@property NSString *evOtherEvse;
@property NSString *otherCharge;
@property NSString *connectorType;
@property CLLocation *location;

@property NSNumber *nrel_id;

+ (void)addAPIDatatoParse;
+ (void)getChargingStationInfoForID:(NSNumber *)nrel_id andCompletion:(void(^)(ChargingStation *chargingStationInfo))completion;
+ (void)saveAPIDataToParse:(NSNumber *)nrel_id andCompletion:(void(^)(PFObject *chargingStationObject))completion;

@end
