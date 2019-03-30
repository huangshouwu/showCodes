//
//  GJTCustomKeyboard.h
//  Lottery
//
//  Created by hsw on 16/2/23.
//  Copyright © 2016年 9188-MacPro1. All rights reserved.
//

#import "GJTBaseView.h"
#import "GJTBaseButton.h"

typedef enum {
    GJTCustomKeyboardTypeNumberPad,     /* 纯数字键盘，无小数点 */
    GJTCustomKeyboardTypeNumAndDotPad,  /* 纯数字键盘，有小数点 */
    GJTCustomKeyboardTypeNumAndXPad,    /* 数字键盘，有字母‘X’ */
}GJTCustomKeyboardType;

typedef NS_ENUM (NSInteger,GJTDeleteButtonTouchState){
    GJTDeleteButtonTouchStateBegan,
    GJTDeleteButtonTouchStateCancelled,
    GJTDeleteButtonTouchStateEnded
};

@interface GJTCustomKeyboard : GJTBaseView

+ (instancetype)keyBoardWithType:(GJTCustomKeyboardType)type;

/** 键盘高度 */
+ (CGFloat )keyBoardHeight;

/** 确定按钮 */
@property (nonatomic,strong)GJTBaseButton* sureButton;

/** 键盘当前类型 */
@property (nonatomic,readonly,assign)GJTCustomKeyboardType keyboardType;

/** 当输入框里面的内容为空时是否禁用确定按钮 */
@property (nonatomic,assign)BOOL disableSureButtonWhenTextFieldNoContent;

/** 当前的响应者 (除UITextField 其他响应者都被忽略) */
- (UITextField*)currentResponderTextField;

@end

@interface GJTDeleteButton : GJTBaseButton

typedef void(^GJTDeleteButtonTouchBlock)(GJTDeleteButton* button,GJTDeleteButtonTouchState);

@property (nonatomic,copy)GJTDeleteButtonTouchBlock touchBlock;

@end
