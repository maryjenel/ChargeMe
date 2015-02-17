//
//  FindLocationOnMapViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/16/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "FindLocationOnMapViewController.h"

@interface FindLocationOnMapViewController () <UISearchBarDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet UILabel *mapLocationAddress;
@property MKPointAnnotation *sharedAnnotation;

@end

@implementation FindLocationOnMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.delegate = self;
}

- (MKPointAnnotation *)newChargingStation
{
    return self.sharedAnnotation;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self findLocationByString:searchBar.text];
    [self.searchBar resignFirstResponder];
}

// Find the location and show it on the map with a pin
-(void)findLocationByString:(NSString *)searchText

{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = searchText;
    request.region = self.mapView.region;

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];

    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        for (MKMapItem *item in response.mapItems)
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = item.placemark.coordinate;
            annotation.title      = item.name;
            annotation.subtitle   = item.placemark.title;
            self.sharedAnnotation = annotation;
            MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.5, 0.5));
            [self.mapView setRegion:region animated:YES];
            [self.mapView addAnnotation:annotation];
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annotationView.canShowCallout = YES;
    self.mapLocationAddress.text = annotation.subtitle;
    return annotationView;
}

@end
