//
//  RecmdListViewController.m
//  MyLauncher
//
//  Created by lxl on 12-11-11.
//
//

#import "RecmdListViewController.h"
#import "RecommendList.h"
#import "RecmdListViewCell.h"
#import "BookDetailsViewController.h"
#import "AppDelegate.h"


@interface RecmdListViewController()
{
    NSMutableArray* books;
}
-(void)loadRecmdList;
@end


@implementation RecmdListViewController

#pragma mark Private
-(void)loadRecmdList
{
    BookEntryBase* bookData= [RecommendList shareInstance];
    if (bookData) {
        books = bookData.books;
        [self.tableView reloadData];
    }
}
- (void) loadView
{
    [super loadView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(datasetChanged:) name:kRecommendDatasetChanged object:nil];
    //self.title = NSLocalizedString(@"RecommendList", @"RecommendList");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return books?[books count]:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RecmdListViewCell *viewCell = (RecmdListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (viewCell == nil) {
        viewCell = [[[RecmdListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
    }
    
    
    RJSingleBook* book = (RJSingleBook *)[books objectAtIndex:indexPath.row];
    viewCell.textLabel.text = book.name;
    viewCell.detailTextLabel.text = [NSString stringWithFormat:@"作者：%@", book.author];
    viewCell.tips = @"";
    [viewCell.imageView initWithImage:[UIImage imageNamed:book.icon]];
    
    
    
    NSUInteger row = [indexPath row];
    //make the background color
    BOOL usrDark = (row % 2 == 0);     //奇偶判定
    if (usrDark) {
        viewCell.contentView.backgroundColor =  [UIColor colorWithRed:234.0f/255.0f green:219.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
    }
    else
    {
        viewCell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return viewCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDetailsViewController *detailViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    detailViewController.book = [books objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super dealloc];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    [self loadRecmdList];
}

#pragma mark datasetChanged
-(void)datasetChanged:(NSNotification*)notification
{
    NSLog(@"%s",__func__);
   [self loadRecmdList];
}

@end
