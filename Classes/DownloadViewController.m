//
//  DownloadViewController.m
//  Hayate
//
//  Created by 韩 国翔 on 11-12-9.
//  Copyright 2011年 山东海天软件学院. All rights reserved.
//

#import "DownloadViewController.h"
#import "LatestBooks.h"
#import "BookEntryBase.h"

#define kViewGroupTag 103
#define  kDownloadingTableView 101
#define kFinishedTableView  102

@implementation DownloadViewController

@synthesize downloadingTable;
@synthesize finishedTable;
//@synthesize downingList;
//@synthesize finishedList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    //[downingList release];
    //[finishedList release];
    [downloadingTable release];
    [finishedTable release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)showFinished
{
    [self startFlipAnimation:0];
}

-(void)showDowning:(BOOL)switchMode{
    if(switchMode)
    {
        [self startFlipAnimation:1];
    }
}

-(void)startFlipAnimation:(NSInteger)type
{    
    //[APPDELEGETE playButtonSound];
    CGContextRef context=UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0f];
    UIView *lastView=[self.view viewWithTag:kViewGroupTag];
    
    if(type==0)
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:lastView cache:YES];
    }
    else
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:lastView cache:YES];
    }
    
    UITableView *frontTableView=(UITableView *)[lastView viewWithTag:kDownloadingTableView];
    UITableView *backTableView=(UITableView *)[lastView viewWithTag:kFinishedTableView];
    NSInteger frontIndex=[lastView.subviews indexOfObject:frontTableView];
    NSInteger backIndex=[lastView.subviews indexOfObject:backTableView];
    [lastView exchangeSubviewAtIndex:frontIndex withSubviewAtIndex:backIndex];
    [UIView commitAnimations];
}

-(void)leaveEdit
{
    [APPDELEGETE playButtonSound];
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(enterEdit)]autorelease];
    [self.downloadingTable setEditing:NO animated:YES];
    [self.finishedTable setEditing:NO animated:YES];
}

-(void)enterEdit
{
    [APPDELEGETE playButtonSound];
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(leaveEdit)]autorelease];
    [self.downloadingTable setEditing:YES animated:YES];
    [self.finishedTable setEditing:YES animated:YES];
}


#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
   
    AppDelegate *appDelegate=APPDELEGETE;
    appDelegate.downloadDelegate=self;
    //self.downingList=appDelegate.downinglist;
    //appDelegate.finishedlist=appDelegate.finishedlist;
     [self setDownloading:[((AppDelegate*)SharedDelegate).downinglist count]];
    [self.downloadingTable reloadData];
    [self.finishedTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect rc = self.tabBarController.view.frame;
    rc.size.height -= self.navigationController.navigationBar.frame.size.height;
    self.finishedTable.frame = rc;
    self.downloadingTable.frame = rc;

    

}
-(void)setDownloading:(BOOL)mode
{
#define kFinishedTableIndex 0
#define kDownloadingTableIndex 1
    
    mInDownloadingView = mode;
    NSString* buttonString = mInDownloadingView?@"已下载":@"下载中";
    self.parentViewController.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc]initWithTitle:buttonString style:UIBarButtonItemStylePlain target:self action:@selector(switchView)]autorelease];
    finishedTable.hidden = mInDownloadingView;
    downloadingTable.hidden = (!mInDownloadingView);
    [self startFlipAnimation:mInDownloadingView?kDownloadingTableIndex:kFinishedTableIndex];
}
-(void)switchView
{
    [self setDownloading:!mInDownloadingView];
}
- (IBAction)segmentAction:(id)sender
{
#define kDownloadedFile 0
#define kReturn 1
	// The segmented control was clicked, handle it here
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSLog(@"Segment clicked: %d", segmentedControl.selectedSegmentIndex);
    if(segmentedControl.selectedSegmentIndex == kDownloadedFile)
    {
        [self showFinished];
    }
    else if(segmentedControl.selectedSegmentIndex == kReturn)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.downloadingTable=nil;
    self.finishedTable=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma 表格数据源

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.downloadingTable)
    {
        return [((AppDelegate*)SharedDelegate).downinglist count];
    }
    else
    {
        return [((AppDelegate*)SharedDelegate).finishedlist count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.downloadingTable)//正在下载的文件列表
    {
        static NSString *downCellIdentifier=@"DownloadCell";
        DownloadCell *cell=(DownloadCell *)[self.downloadingTable dequeueReusableCellWithIdentifier:downCellIdentifier];
        if(cell==nil)
        {
            NSArray *objlist=[[NSBundle mainBundle] loadNibNamed:@"DownloadCell" owner:self options:nil];
            for(id obj in objlist)
            {
                if([obj isKindOfClass:[DownloadCell class]])
                {
                    cell=(DownloadCell *)obj;
                }
            }
        }
        ASIHTTPRequest *theRequest=[((AppDelegate*)SharedDelegate).downinglist objectAtIndex:indexPath.row];
        FileModel *fileInfo=[theRequest.userInfo objectForKey:@"File"];
        cell.fileName.text=fileInfo.fileName;
        cell.fileSize.text=fileInfo.fileSize;
        cell.fileInfo=fileInfo;
        cell.request=theRequest;
        cell.fileCurrentSize.text=[CommonHelper getFileSizeString:fileInfo.fileReceivedSize];
        [cell.progress setProgress:[CommonHelper getProgress:[CommonHelper getFileSizeNumber:fileInfo.fileSize] currentSize:[fileInfo.fileReceivedSize floatValue]]];
        if(fileInfo.isDownloading==YES)//文件正在下载
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"downloading_go.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"downloading_stop.png"] forState:UIControlStateNormal];
        }
        return cell;
    }
    else if(tableView==self.finishedTable)//已完成下载的列表
    {
        static NSString *finishedCellIdentifier=@"FinishedCell";
        FinishedCell *cell=(FinishedCell *)[self.finishedTable dequeueReusableCellWithIdentifier:finishedCellIdentifier];
        if(cell==nil)
        {
            NSArray *objlist=[[NSBundle mainBundle] loadNibNamed:@"FinishedCell" owner:self options:nil];
            for(id obj in objlist)
            {
                if([obj isKindOfClass:[FinishedCell class]])
                {
                    cell=(FinishedCell *)obj;
                }
            }
        }
        FileModel *fileInfo=[((AppDelegate*)SharedDelegate).finishedlist objectAtIndex:indexPath.row];
        cell.fileNameLabel.text=fileInfo.fileName;
        cell.fileSizeLabel.text=fileInfo.fileSize;
        cell.fileInfo=fileInfo;
        return cell;
    }
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)//点击了删除按钮,注意删除了该视图列表的信息后，还要更新UI和APPDelegate里的列表
    {
        AppDelegate* appDelegate = ((AppDelegate*)SharedDelegate);
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        if(tableView.tag==kDownloadingTableView)//正在下载的表格
        {
            ASIHTTPRequest *theRequest=[((AppDelegate*)SharedDelegate).downinglist objectAtIndex:indexPath.row];
            if([theRequest isExecuting])
            {
                [theRequest cancel];
            }
            FileModel *fileInfo=(FileModel*)[theRequest.userInfo objectForKey:@"File"];
                        
            NSString *path=[[CommonHelper getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileInfo.fileName]];
            NSInteger index=[fileInfo.fileName rangeOfString:@"."].location;
            NSString *name=[fileInfo.fileName substringToIndex:index];
            NSString *configPath=[[CommonHelper getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",name]];
            [fileManager removeItemAtPath:path error:&error];
            [fileManager removeItemAtPath:configPath error:&error];
            if(!error)
            {
                NSLog(@"%@",[error description]);
            }
            [appDelegate.downinglist removeObjectAtIndex:indexPath.row];
            [self.downloadingTable reloadData];
        }
        else//已经完成下载的表格
        {            
            FileModel *selectFile=[appDelegate.finishedlist objectAtIndex:indexPath.row];
            [CommonHelper deleteFinishedBook:selectFile];
//            [appDelegate.finishedlist removeObject:selectFile];
            [appDelegate.finishedlist removeObjectAtIndex:indexPath.row];
            [self.finishedTable reloadData];
        }
    }
}

-(void)updateCellOnMainThread:(FileModel *)fileInfo
{
    for(id obj in self.downloadingTable.subviews)
    {
        if([obj isKindOfClass:[DownloadCell class]])
        {
            DownloadCell *cell=(DownloadCell *)obj;
            if(cell.fileInfo.fileURL==fileInfo.fileURL)
            {
                cell.fileCurrentSize.text=[CommonHelper getFileSizeString:fileInfo.fileReceivedSize];
                cell.fileSize.text = fileInfo.fileSize;
                [cell.progress setProgress:[CommonHelper getProgress:[CommonHelper getFileSizeNumber:fileInfo.fileSize] currentSize:[fileInfo.fileReceivedSize floatValue]]];
            }
        }
    }
}

#pragma 下载更新界面的委托
-(void)startDownload:(ASIHTTPRequest *)request;
{
    NSLog(@"-------开始下载!");
}

-(void)updateCellProgress:(ASIHTTPRequest *)request;
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

-(void)finishedDownload:(ASIHTTPRequest *)request;
{
    [self.downloadingTable reloadData];
    [self.finishedTable reloadData];
}


@end
