# EESlider
已适配屏幕旋转和自动对齐,标签始终显示在正中

默认线条样式:

 ![image](https://github.com/xiaoyishan/EESlider/blob/master/eeline.png)
 ![image](https://github.com/xiaoyishan/EESlider/blob/master/eeslider.png)

展示样式:

```objective-c
typedef enum : NSUInteger {
    EESliderStyleDefault,        // 不均匀大小,长度自动扩充
    EESliderStyleEquational,     // 强制等分成相同大小
    EESliderStyleAutoEquational, // 在屏幕能完整显示的情况下均分,超出则不再均分
} EESliderStyle;
```
