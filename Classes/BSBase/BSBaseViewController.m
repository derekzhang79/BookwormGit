//
//  BSBaseViewController.m
//  MyLauncher
//
//  Created by lxl on 12-11-26.
//
//

#import "BSBaseViewController.h"

@interface BSBaseViewController ()

@end

@implementation BSBaseViewController
@synthesize backgroundImageView = _backgroundImageView;

- (void)dealloc {
    [_backgroundImageView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 背景色
    UIColor *backgroundColor = COLOR(234,237,250);
    self.view.backgroundColor = backgroundColor;
    
    
}

-(void)addBackgroundImageView:(UIImage*) image
{
    //设置背景图片
    UIImageView *backview=[[UIImageView alloc] initWithImage:image];
    backview.frame=CGRectMake(0, 0, 320, 480);
    [self.view addSubview:backview];
}


@end
