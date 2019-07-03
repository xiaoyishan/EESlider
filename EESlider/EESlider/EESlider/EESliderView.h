//
//  EESliderView.h
//  EEMobilePortal
//
//  Created by aosue on 2019/1/10.
//  Copyright © 2019 xiexin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EESliderStyleDefault,        // 不均匀大小,长度自动扩充
    EESliderStyleEquational,     // 强制等分成相同大小
    EESliderStyleAutoEquational, // 在屏幕能完整显示的情况下均分,超出则不再均分
} EESliderStyle;

@interface EESliderView : UIView

@property (nonatomic,strong) UIScrollView *scrollerView;
@property (nonatomic,strong) UILabel *LineLabel;
@property (nonatomic,strong) NSMutableArray *Views;

@property (nonatomic,strong) NSArray<NSString*> *titleList; // <展示的标题>
@property (nonatomic,assign,readonly) NSInteger currentDex;

// 展示样式
@property (nonatomic,assign) EESliderStyle style;

// dapp样式：字体选中加粗 线条缩短加粗至3pt，圆角2
@property (nonatomic,assign) BOOL isRoundStyle;
// 字体上下偏移比例 0.01～1.0范围有效
@property (nonatomic,assign) CGFloat paddingY;

typedef void (^ButtonClickBlock)(NSString *name,NSInteger dex);
- (void)showAndDone:(ButtonClickBlock)done;
// 高亮
-(void)makeThePointHighLight:(NSInteger)dex;

@end

NS_ASSUME_NONNULL_END
