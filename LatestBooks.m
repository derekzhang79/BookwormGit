//
//  LatestBooks.m
//  MyLauncher
//
//  Created by ramonqlee on 10/15/12.
//
//

#import "LatestBooks.h"
#import "Tree.h"

static LatestBooks *shareBookData = nil;
@implementation LatestBooks
+(LatestBooks*)shareInstance{
    @synchronized(self){
        if(shareBookData == nil){
            shareBookData = [[LatestBooks alloc] initWithEntry:kLatestEntry];
        }
    }
    return shareBookData;
}

@end
