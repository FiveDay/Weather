//
//  WTClient.m
//  Weather
//
//  Created by zzyy on 14/6/15.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTClient.h"
#import "WTDataModel.h"

@interface WTClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WTClient

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);
    
    // 1
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 2
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // TODO: Handle retrieved data
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    // 1
                    [subscriber sendNext:json];
                }
                else {
                    // 2
                    [subscriber sendError:jsonError];
                } 
            } 
            else { 
                // 2 
                [subscriber sendError:error]; 
            } 
            
            // 3 
            [subscriber sendCompleted];
        }];
        
        // 3
        [dataTask resume];
        
        // 4
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        // 5
        NSLog(@"%@",error);
    }]; 
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    // 1
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 3
        return [MTLJSONAdapter modelOfClass:[WTDataModel class] fromJSONDictionary:json error:nil];
    }];
}
@end
