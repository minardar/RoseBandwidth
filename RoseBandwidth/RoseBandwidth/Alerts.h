//
//  Alerts.h
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 2/6/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alerts : NSManagedObject

@property (nonatomic, retain) NSNumber * threshold;
@property (nonatomic, retain) NSString * alertName;
@property (nonatomic, retain) NSNumber * isEnabled;

@end
