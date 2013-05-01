//
//  ViewController.m
//  MapKitDelegateBug
//
//  Created by Rob Phillips on 5/1/13.
//  Copyright (c) 2013 Rob Phillips. All rights reserved.
//

#import "Reachability.h"
#import "ViewController.h"

@interface ViewController ()
{
    Reachability *internetReachable;
}
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Test if we have an internet connection (we don't want one)
    internetReachable = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"We have an internet connection, and we shouldn't have one.  This bug example has to be performed on a device without an internet connection. Please disconnect the internet connection and run this example again."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Info"
                                                         message:@"Now that the internet is disconnected, please look at the debug console for NSLog statements of what you should be seeing in this bug example."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        });
    };
    
    [internetReachable startNotifier];
    
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    NSLog(@"Map started loading.");
}

// There is an issue with this delegate method being called even though the map doesn't fully render
// especially when the internet connection is down and you're at a zoom level or part of the map
// where there aren't any cached tiles.
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    NSLog(@"The mapView stated that it finished loading, but is this true?  Pan and zoom to an area without cached tiles and check if you still get this callback.");
}

// This never gets called, even though the map doesn't render at a lower zoom level
// when it doesn't have cache available or an internet connection to retrieve the tiles
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"The map had an error loading, but this delegate never gets called so we don't know that.");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Panned and/or zoomed the map.  Did you pan and zoom to a section of the map where there aren't any cached tiles?  If so, you will see that mapViewDidFinishLoadingMap: was called even though the mapView actually didn't finish loading the map successfully.  mapViewDidFinishLoadingMap: should ONLY be called after the map has successfully rendered all of the tiles, not before and not falsely like in this example.");
}

@end
