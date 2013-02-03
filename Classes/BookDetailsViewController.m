//
//  BookDetailsViewController.m
//  MyLauncher
//
//  Created by lxl on 12-11-11.
//
//

#import "BookDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "FileModel.h"
#import "CommonHelper.h"
#import "AppDelegate.h"
#import "RJBookData.h"

@interface BookDetailsViewController ()

@end

@implementation BookDetailsViewController
@synthesize bookIconImageView = _bookIconImageView;
@synthesize bookAuthor = _bookAuthor;
@synthesize bookName = _bookName;
@synthesize boolTotalChar = _boolTotalChar;
@synthesize downLoadBtn = _downLoadBtn;
@synthesize summuryView = _summuryView;
@synthesize lineImage = _lineImage;

-(void)dealloc
{
    self.bookIconImageView = nil;
    self.bookAuthor = nil;
    self.bookName = nil;
    self.boolTotalChar = nil;
    self.downLoadBtn = nil;
    self.summuryView = nil;
    self.lineImage = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.bookIconImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:self.book.icon]] autorelease];
    [self.bookIconImageView initWithImage:[UIImage imageNamed:self.book.icon]];
    self.bookAuthor.text = [NSString stringWithFormat:@"[作者]:%@", self.book.author];
    self.bookName.text = self.book.name;
    self.boolTotalChar.text = [NSString stringWithFormat:@""];
    self.summuryView.text = self.book.summary;
    self.title = self.book.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)downLoadBtnPressed:(id)sender
{
    NSLog(@"downLoadBtnPressed");
    FileModel *selectFileInfo= [FileModel fileModelFromRJSingleBook:self.book];
    
    //因为是重新下载，则说明肯定该文件已经被下载完，或者有临时文件正在留着，所以检查一下这两个地方，存在则删除掉
    NSString *targetPath=[[CommonHelper getTargetFolderPath]stringByAppendingPathComponent:selectFileInfo.fileName];
    //[CommonHelper makesureDirExist:targetPath];
    NSString *tempPath=[[[CommonHelper getTempFolderPath]stringByAppendingPathComponent:selectFileInfo.fileName]stringByAppendingString:@".temp"];
    if([CommonHelper isExistFile:targetPath])//已经下载过一次该音乐
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已经添加到您的下载列表中了！是否重新下载该文件？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        return;
    }
    //存在于临时文件夹里
    if([CommonHelper isExistFile:tempPath])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已经添加到您的下载列表中了！是否重新下载该文件？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        return;
    }
    selectFileInfo.isDownloading=YES;
    //若不存在文件和临时文件，则是新的下载
    AppDelegate *appDelegate=APPDELEGETE;
    [appDelegate beginRequest:selectFileInfo isBeginDown:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)//确定按钮
    {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        AppDelegate *appDelegate=APPDELEGETE;
        FileModel *fileInfo= [FileModel fileModelFromRJSingleBook:self.book];

        NSString *targetPath=[[CommonHelper getTargetFolderPath]stringByAppendingPathComponent:fileInfo.fileName];
        NSString *tempPath=[[[CommonHelper getTempFolderPath]stringByAppendingPathComponent:fileInfo.fileName]stringByAppendingString:@".temp"];
        if([CommonHelper isExistFile:targetPath])//已经下载过一次该音乐
        {
            [fileManager removeItemAtPath:targetPath error:&error];
            if(!error)
            {
                NSLog(@"删除文件出错:%@",error);
            }
            for(FileModel *file in appDelegate.finishedlist)
            {
                if([file.fileName isEqualToString:fileInfo.fileName])
                {
                    [appDelegate.finishedlist removeObject:file];
                    break;
                }
            }
        }
        //存在于临时文件夹里
        if([CommonHelper isExistFile:tempPath])
        {
            [fileManager removeItemAtPath:tempPath error:&error];
            if(!error)
            {
                NSLog(@"删除临时文件出错:%@",error);
            }
        }
        
        for(ASIHTTPRequest *request in appDelegate.downinglist)
        {
            FileModel *fileModel=[request.userInfo objectForKey:@"File"];
            if([fileModel.fileName isEqualToString:fileInfo.fileName])
            {
                [appDelegate.downinglist removeObject:request];
                break;
            }
        }
        
        fileInfo.isDownloading=YES;
        fileInfo.fileReceivedSize=[CommonHelper getFileSizeString:@"0"];
        [appDelegate beginRequest:fileInfo isBeginDown:YES];
    }
}

@end
