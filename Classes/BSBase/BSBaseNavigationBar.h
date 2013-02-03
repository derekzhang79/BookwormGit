//
//  BSBaseNavigationBar.h
//  MyLauncher
//
//  Created by lxl on 12-11-26.
//
//

#import <UIKit/UIKit.h>

@interface BSBaseNavigationBar : UIView <UIGestureRecognizerDelegate>
{
    // 背景
    UIImageView *_backgroundView;
    // 返回按钮
    UIButton *_backButton;
    // 右侧按钮
    UIButton *_rightButton;
    // 标题
    NSString *_title;
    // 标题Label
    UILabel *_titleLabel;
    // 右侧按钮
    NSMutableArray *_extendButtons;
    // 最大扩展按钮数
    NSUInteger _maxExtendButtonCount;
    // 是否为目录
    BOOL _isCatalog;
}

@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, readonly) UIButton *backButton;
//右侧按钮，右侧按钮和右侧扩展按钮二选一
@property (nonatomic, retain) UIButton *rightButton;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UILabel *titleLabel;
// 清理backBtn，因为push时设置了target，清理掉才能保证自己定义target调用
- (void)clearBackBtn;
@property (nonatomic, retain) NSMutableArray *extendButtons;
@property (nonatomic, readonly) CGFloat barHeight;
// 返回按钮是否可用，NO会隐藏返回按钮，默认为YES
@property (nonatomic, assign) BOOL backButtonEnable;
// 默认为NO
@property (nonatomic, assign) BOOL expandEnable;
@property (nonatomic, assign) BOOL rightButtonEnable;
@property (nonatomic, assign) BOOL isCatalog;

/*
 * 添加一个扩展按钮
 *
 * @target 按钮执行目标
 * @touchUpInSideSelector 在按钮上抬起时的执行方法
 * @normalImage 按钮普通图标
 * @highlightedImage 按钮高亮图标
 *
 * @return 是否添加按钮成功
 */
- (BOOL)addExtendButtonWithTarget:(id)target
            touchUpInSideSelector:(SEL)selector
                      normalImage:(UIImage *)normalImage
                 highlightedImage:(UIImage *)highlightedImage;

/*
 * 添加一组扩展按钮
 *
 * @buttons 添加按钮对象数组
 *
 * @return 是否添加成功
 */
- (BOOL)addExtendButtons:(NSArray *)buttons;

/*
 * 添加一个扩展按钮
 *
 * @button 添加的按钮对象
 *
 * @return 是否添加按钮成功，失败的原因可能是因为按钮数超过最大允许数量（默认3）
 */
- (BOOL)addExtendButton:(UIButton *)button;

/*
 * 清空所有扩展按钮
 */
- (void)cleanExtendButtons;

/*
 * 设置扩展按钮及右按钮是否有效
 */
- (void)setExtendButtonsEnable:(BOOL)enable;

@end
