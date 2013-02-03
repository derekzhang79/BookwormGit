//
//  BSBaseTableViewController.m
//  MyLauncher
//
//  Created by lxl on 12-11-26.
//
//

#import "BSBaseTableViewController.h"

@interface BSBaseTableViewController ()

@end

@implementation BSBaseTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 背景色
    UIColor *backgroundColor = COLOR(234,237,250);
    self.view.backgroundColor = backgroundColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
