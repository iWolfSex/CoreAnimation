//
//  AppDelegate.h
//  LCAnimationDemo1
//
//  Created by 刘超 on 2021/3/28.
//  Copyright © 2021 刘超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

