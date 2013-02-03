//
//  RecmdListViewCell.m
//  MyLauncher
//
//  Created by lxl on 12-11-11.
//
//

#import "RecmdListViewCell.h"

@interface RecmdListViewCell ()

@property (nonatomic, retain) UILabel* tipLable;

@end

@implementation RecmdListViewCell
@synthesize tips = _tips;
@synthesize tipLable = _tipLable;


- (void)dealloc
{
    self.tips = nil;
    self.tipLable = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.tipLable = nil;
    self.tips = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tipLable.center = CGPointMake(self.tipLable.center.x, self.contentView.center.y);
}

-(UILabel*)tipLable
{
    if (_tipLable ==nil) {
        _tipLable = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100 - 10, 0, 100, 40)];
        _tipLable.textAlignment = UITextAlignmentRight;
        _tipLable.font = [UIFont systemFontOfSize:16.0f];
        _tipLable.backgroundColor = [UIColor clearColor];
        self.tipLable.text = self.tips;
        [self addSubview:_tipLable];
    }
    return _tipLable;
}

@end
