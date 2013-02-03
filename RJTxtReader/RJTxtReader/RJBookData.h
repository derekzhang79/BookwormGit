//
//  RJBookData.h
//  txtReader
//
//  Created by Zeng Qingrong on 12-8-22.
//  Copyright (c) 2012年 Zeng Qingrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookEntryBase.h"

//对外提供图书数据的访问接口
@interface RJBookData : BookEntryBase

+(RJBookData*)sharedRJBookData;

@end
