//
//  EESliderView.m
//  EEMobilePortal
//
//  Created by aosue on 2019/1/10.
//  Copyright © 2019 xiexin. All rights reserved.
//

#import "EESliderView.h"
#import "Masonry.h"
#import <objc/runtime.h>

#define MPDarkTextColor         [UIColor darkTextColor]
#define MPTintColor             [UIColor orangeColor]
#define KFONTRegular(x)         [UIFont systemFontOfSize:x]
#define MPLineColor             [UIColor lightGrayColor]
#define kPoint                  (1 / [UIScreen mainScreen].scale)
#define KFONTMedium(x)          [UIFont boldSystemFontOfSize:x]

static CGFloat sliderHH = 50.0;

@interface EESliderView ()
@property (nonatomic,assign) BOOL isOutOfView;
@end

@implementation EESliderView

- (void)showAndDone:(ButtonClickBlock)done{
    [self removeFromSuperview];
    if (_titleList.count == 0) {
        return;
    }
    [UIColor lightGrayColor];
    
    if (self.frame.size.height > 0) {
        sliderHH = self.frame.size.height;
    }
    
    [self addSubview:self.scrollerView];
    [self.scrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.height.equalTo(@(sliderHH));
    }];
    
    // 自动模式中先计算是否符合固定或延伸的要求
    if (_style == EESliderStyleAutoEquational) {
        self.isOutOfView = [self isOutOfView];
    }
    
    for (int k=0; k<_titleList.count; k++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        //button.backgroundColor = kRandColor;
        button.titleLabel.font = KFONTRegular(16);
        button.tag = 1000+k;
        [button setTitle:_titleList[k] forState:UIControlStateNormal];
        [button setTitleColor:MPDarkTextColor forState:UIControlStateNormal];
        [button setTitleColor:MPTintColor forState:UIControlStateSelected];
        [self.scrollerView addSubview:button];
        [self.Views addObject:button];
        objc_setAssociatedObject(button, @"doneBlock", done, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 文字上下调整 1:50-18  0.1:-50+18
        if (_paddingY >0 && _paddingY <=1) {
            CGFloat yy = sliderHH * _paddingY*2 - sliderHH;
            yy = _paddingY>0.5 ? yy-18 : yy+18;
            button.titleEdgeInsets = UIEdgeInsetsMake(yy, 0, 0, 0);
        }
        
        // 默认选中第一个
        if (k == 0) {
            button.selected = YES;
        }
        
        // 最后一个
        if (k == _titleList.count-1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.scrollerView setContentSize:CGSizeMake(CGRectGetMaxX(button.frame), 0)];
            });
        }
        CGFloat ww = [self caculateWidthLabel:button.titleLabel andWithSize:CGSizeMake(1000, 20)].width;
        UIButton *oldButton = [_scrollerView viewWithTag:button.tag-1];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.height.equalTo(@(sliderHH));
            if (self->_style == EESliderStyleDefault || (self->_style == EESliderStyleAutoEquational && self->_isOutOfView)) {
                make.width.equalTo(@(ww+15));
                make.left.equalTo(oldButton.mas_right?oldButton.mas_right:@0);
            }else{
                make.width.equalTo(@(self.frame.size.width/self->_titleList.count));
                make.left.mas_equalTo(self.frame.size.width/self->_titleList.count*k);
            }
        }];
    }
    
    // 底线
    UILabel *line = [UILabel new];
    line.backgroundColor = MPLineColor;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(@(sliderHH));
        make.height.equalTo(@(kPoint));
    }];
    
    // 活动线条
    UIButton *oldButton = [_scrollerView viewWithTag:1000];
    [self.scrollerView addSubview:self.LineLabel];
    if (oldButton) {
        [self.LineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat hh = self->_isRoundStyle?3:2;
            CGFloat bot = self.isRoundStyle ?3 : 0;
            make.top.equalTo(@(sliderHH-hh-bot));
            make.height.equalTo(@(hh));
            make.centerX.equalTo(oldButton.mas_centerX);
            make.width.equalTo(@([self GetButtonLableDistance:oldButton]));
        }];
    }
    
}

-(void)buttonClick:(UIButton*)btn{
    ButtonClickBlock done = objc_getAssociatedObject(btn, @"doneBlock");
    _currentDex = btn.tag - 1000;
    [self makeThePointHighLight:_currentDex];
    if(done)done(self->_titleList[_currentDex],_currentDex);
}

// 高亮
-(void)makeThePointHighLight:(NSInteger)dex {
    
    UIButton *btn = self.Views[dex];
    [self updateSelectButton:btn];
    [self updateActiveLine:btn];
    
}
// 旋转屏幕偏移处理
-(void)layoutSubviews {
    [super layoutSubviews];
    [self updateSelectButton:_Views[_currentDex]];
}
// 更新按钮颜色
- (void)updateSelectButton:(UIButton*)button {
    for (UIButton *subButton in self.Views) {
        if (subButton.tag != button.tag) {
            subButton.selected = NO;
            subButton.titleLabel.font = KFONTRegular(16);
        }
    }
    [button setSelected:YES];
    if (_isRoundStyle) button.titleLabel.font = KFONTMedium(16);
    
    // 调整位置
    if (self->_style == EESliderStyleDefault || (self->_style == EESliderStyleAutoEquational && self->_isOutOfView)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 起始不足一半的偏移量 x固定未0
            if (CGRectGetMaxX(button.frame)+10 < self.frame.size.width/2.0) {
                [self.scrollerView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            
            // 假如剩余空间足够大,直接显示在正中间
            else if (self->_scrollerView.contentSize.width > CGRectGetMaxX(button.frame)-button.frame.size.width/2.0 + self.frame.size.width/2.0) {
                [self.scrollerView setContentOffset:CGPointMake(CGRectGetMaxX(button.frame)+10-(button.frame.size.width+self.frame.size.width)/2.0, 0) animated:YES];
            }
            
            // 终止剩余不足一半并且最大值大于显示区域 x固定为最大值
            else{
                [self.scrollerView setContentOffset:CGPointMake(self->_scrollerView.contentSize.width-self.frame.size.width, 0) animated:YES];
            }
            
        });
    }
}
// 计算是否内容是否超出显示空间,跟isAutoEquational有关
-(BOOL)isOutOfView {
    CGFloat ww =0;
    for (int k=0; k<_titleList.count; k++) {
        UIButton *button = [[UIButton alloc] init];
        button.titleLabel.font = KFONTRegular(16);
        [button setTitle:_titleList[k] forState:UIControlStateNormal];
        ww = ww + [self caculateWidthLabel:button.titleLabel andWithSize:CGSizeMake(1000, 20)].width;
    }
    if (ww > self.frame.size.width+5) return YES;
    return NO;
}
// 更新滑动条
- (void)updateActiveLine:(UIButton*)button {
    if(!button) return;
    [self layoutIfNeeded];
    [UIView animateWithDuration:.35 animations:^{
        [self.LineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat hh = self->_isRoundStyle?3:2;
            CGFloat bot = self.isRoundStyle ?3 : 0;
            make.top.equalTo(@(sliderHH-hh-bot));
            make.height.equalTo(@(hh));
            make.centerX.equalTo(button.mas_centerX);
            make.width.equalTo(@([self GetButtonLableDistance:button]));
        }];
        [self layoutIfNeeded];
    }];
}

- (CGFloat)GetButtonLableDistance:(UIButton*)button {
    if (!button) return 0.0;
    UILabel *label = [[UILabel alloc] initWithFrame:button.frame];
    label.font = button.titleLabel.font;
    label.text = button.currentTitle;
    [label sizeToFit];
    if (_isRoundStyle) return 20;
    return label.frame.size.width;
}
//计算label size
-(CGSize)caculateWidthLabel:(UILabel*)label andWithSize:(CGSize )asize {
    CGSize size = [label.text boundingRectWithSize:asize options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName :label.font} context:nil].size;
    return size;
}


-(NSMutableArray *)Views {
    if (_Views) return _Views;
    _Views = [NSMutableArray new];
    return _Views;
}
-(UIScrollView *)scrollerView {
    if (_scrollerView) return _scrollerView;
    _scrollerView = [UIScrollView new];
    _scrollerView.frame = CGRectMake(0, 0, self.frame.size.width, sliderHH);
    _scrollerView.backgroundColor = [UIColor whiteColor];
    _scrollerView.showsVerticalScrollIndicator = NO;
    _scrollerView.showsHorizontalScrollIndicator = NO;
    return _scrollerView;
}
-(UILabel *)LineLabel {
    if (_LineLabel) return _LineLabel;
    _LineLabel = [UILabel new];
    _LineLabel.frame = CGRectMake(100, sliderHH-2, 100, 2);
    _LineLabel.backgroundColor = MPTintColor;
    if (_isRoundStyle) {
        _LineLabel.layer.cornerRadius = 2.0;
        _LineLabel.clipsToBounds = YES;
    }
    return _LineLabel;
}


@end
