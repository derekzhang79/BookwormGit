//
//  RJBookData.m
//  txtReader
//
//  Created by Zeng Qingrong on 12-8-22.
//  Copyright (c) 2012年 Zeng Qingrong. All rights reserved.
//

#import "RJBookData.h"
#import "Tree.h"
#import "CommonHelper.h"
@implementation RJBookData


static RJBookData *shareBookData = nil;

+(RJBookData*)sharedRJBookData{
    @synchronized(self){
        if(shareBookData == nil){
            shareBookData = [[RJBookData alloc] initWithEntry:kBookEntry];
        }
    }
    return shareBookData;
}
@end
