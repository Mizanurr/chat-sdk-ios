//
//  BLocationOption.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 17/12/2016.
//
//

#import "BLocationChatOption.h"
#import <ChatSDK/ChatCore.h>
#import <ChatSDK/ChatUI.h>

@implementation BLocationChatOption

@synthesize parent;

-(UIImage *) icon {
    return [UIImage imageNamed:@"ChatUI.bundle/icn_60_location.png"];
}

-(NSString *) title {
    return [NSBundle t:bLocation];
}

-(RXPromise *) execute {
    
    if(_promise) {
        return _promise;
    }
    else {
        _promise = [RXPromise new];
    }

    if(!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    [_locationManager startUpdatingLocation];
    
    return _promise;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [manager stopUpdatingLocation];
    if(_locationManager) {
        _locationManager = nil;
        
        CLLocation * location = locations.lastObject;
        
        if ([BNetworkManager sharedManager].a.locationMessage) {
            [_promise resolveWithResult: [[BNetworkManager sharedManager].a.locationMessage sendMessageWithLocation:location
                                                                                                 withThreadEntityID:parent.delegate.currentThread.entityID]];
            [self.parent.delegate reloadData];
            _promise = Nil;
        }
    }
    if(_promise) {
        [_promise resolveWithResult: Nil];
        _promise = Nil;
    }
}


@end
