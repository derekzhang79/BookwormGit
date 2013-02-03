//
//  RecommendList.m
//  MyLauncher
//
//  Created by ramonqlee on 12/29/12.
//
//

#import "RecommendList.h"
#import "Tree.h"

static RecommendList *shareBookData = nil;
@implementation RecommendList
+(RecommendList*)shareInstance{
    @synchronized(self){
        if(shareBookData == nil){
            shareBookData = [[RecommendList alloc] initWithEntry:kRecommendList];
        }
    }
    return shareBookData;
}
@end
