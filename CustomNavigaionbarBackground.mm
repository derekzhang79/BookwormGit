//
//  CustomNavigaionbarBackground.mm
//  MyLauncher
//
//  Created by ramonqlee on 12/1/12.
//
//

#import "CustomNavigaionbarBackground.h"

@implementation UINavigationBar (CustomNavigaionbarBackground)
//重写navbar
//- (UIImage *)barBackground{
//    UIImage* image = [UIImage imageNamed:kNavigationBarBackground];
//    if ([image respondsToSelector:@selector(resizedImage:interpolationQuality:)]) {
//        image = [image resizedImage:self.frame.size interpolationQuality:kCGInterpolationDefault];
//    }
//    return image;
//}
//- (void)didMoveToSuperview{
//    //iOS5 only
//    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
//    {
//        [self setBackgroundImage:[self barBackground] forBarMetrics:UIBarMetricsDefault];
//    }
//}
////this doesn't work on iOS5 but is needed for iOS4 and earlier
//- (void)drawRect:(CGRect)rect{
//    //draw image
//    [[self barBackground] drawInRect:rect];
//}
@end