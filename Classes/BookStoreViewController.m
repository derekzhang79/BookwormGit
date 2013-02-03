//
//  MainViewController.m
//  MyLauncher
//
//  Created by lxl on 12-11-11.
//
//

#import "BookStoreViewController.h"
#import "RecmdListViewController.h"
#import "DownloadViewController.h"
#import "ClassCataloguesViewController.h"

@interface BookStoreViewController ()

@end

@implementation BookStoreViewController
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
		_revealBlock = [revealBlock copy];
		self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(revealSidebar)]autorelease];
	}
	return self;
}
- (void)revealSidebar {
	_revealBlock();
}
- (id)init
{
    self = [super init];
    if (self) {
        self.tabBar.tintColor = COLOR(2, 100, 162);
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    RecmdListViewController* recmdListVC = [[[RecmdListViewController alloc] init] autorelease];
    recmdListVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"RecommendList", @"RecommendList") image:[UIImage imageNamed:kIconRecommend] tag:RecmdItemTag];
    
    ClassCataloguesViewController* clsClgVC = [[[ClassCataloguesViewController alloc] init] autorelease];
    clsClgVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"全部" image:[UIImage imageNamed:kIconBookList] tag:ClassCataloguesTag];
    
    DownloadViewController* downLoadVC = [[[DownloadViewController alloc] init] autorelease];
    downLoadVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"下载" image:[UIImage imageNamed:kIconDownload] tag:DownloadTag];
    self.viewControllers = [NSArray arrayWithObjects:recmdListVC,clsClgVC,downLoadVC, nil];
    self.selectedIndex = 0;
    self.title = NSLocalizedString(@"RecommendList", @"RecommendList");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag) {
        case RecmdItemTag:
            self.title = @"推荐";
            break;
        case ClassCataloguesTag:
            self.title = @"分类";
            break;
        case DownloadTag:
            self.title = @"下载";
            break;
        default:
            break;
    }
}

@end
