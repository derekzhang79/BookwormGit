//
//  GHMenuTitle.m
//  MyLauncher
//
//  Created by lxl on 12-11-25.
//
//

#import "GHMenuTitle.h"

@implementation GHMenuTitle

- (id)initWithTitle:(NSString*)title iconImage:(UIImage*)iconImage
{
    self = [super initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 43.0f)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UILabel* titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(43+15, 0, 100, 30)] autorelease];
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.text = NSLocalizedString(title, title);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.center = CGPointMake(titleLabel.center.x, self.center.y);
        
        UIImageView* iconImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 43, 43)] autorelease];
        iconImageView.image = iconImage;
        iconImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:iconImageView];
        [self addSubview:titleLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
