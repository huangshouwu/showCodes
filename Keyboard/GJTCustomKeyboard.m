//
//  GJTCustomKeyboard.m
//  Lottery
//
//  Created by hsw on 16/2/23.
//  Copyright © 2016年 9188-MacPro1. All rights reserved.
//

#import "GJTCustomKeyboard.h"

static CGFloat        const GJTCustomKeyboardDeleteButtonWidth            = 80.0f;
static NSInteger      const GJTCustomKeyboardNumberButtonCountEveryRow    = 3;
static NSInteger      const GJTCustomKeyboardNumberButtonCountEveryCollom = 4;
static UIEdgeInsets   const GJTCustomKeyboardNumberContentInsets          = {0.5f,0.0f,0.0f,0.0f};
static CGFloat        const GJTCustomKeyboardNumberButtonHeight           = 50.0f;

@interface GJTCustomKeyboard ()<UIGestureRecognizerDelegate>{
    NSArray                *_numerPadArray;/* 数字区域的值 */
    NSMutableArray         *_numerPadButtonArray;/* 数字区域的按钮 */
    GJTCustomKeyboardType _keyboardType;
    NSTimer                *_deleteTimer;
}

@property (nonatomic,strong)GJTDeleteButton* deleteButton;
@property (nonatomic,strong)GJTBaseButton* registerFirstResponderButton;
@property (nonatomic,strong)UIView *bottomSafeView;//iPhone X适配的view
@property (nonatomic,strong)CALayer *bottomLine;//iPhone X适配的view的底部细线
@end

@implementation GJTCustomKeyboard

#pragma mark Public-Method
+ (CGFloat )keyBoardHeight{
    return GJTCustomKeyboardNumberContentInsets.top + GJTCustomKeyboardNumberContentInsets.bottom +  (1.0 / [UIScreen mainScreen].scale)*(GJTCustomKeyboardNumberButtonCountEveryCollom-1) + GJTCustomKeyboardNumberButtonCountEveryCollom*GJTCustomKeyboardNumberButtonHeight + GJTBottomSafeMargin;
}

+ (instancetype)keyBoardWithType:(GJTCustomKeyboardType)type{
    return [[GJTCustomKeyboard alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), [GJTCustomKeyboard keyBoardHeight]) type:type];
}

- (instancetype)initWithFrame:(CGRect)frame type:(GJTCustomKeyboardType)type{
    self = [super initWithFrame:frame];
    if (self) {
        _keyboardType = type;
        //背景色为分割线
        self.backgroundColor = GJTColorForHex(@"#cccccc");
        [self createNumberPadButtonWithType:type];
        [self addSubview:self.deleteButton];
        [self addSubview:self.registerFirstResponderButton];
        [self addSubview:self.sureButton];
        if (isiPhoneX) {
            [self addSubview:self.bottomSafeView];
            [self.bottomSafeView.layer addSublayer:self.bottomLine];
        }
        self.disableSureButtonWhenTextFieldNoContent = YES;
    }
    return self;
}

- (UITextField*)currentResponderTextField{
    UITextField* _responderTextField = (UITextField*)[self findFirstResponder]; //耗时0.0113s,界面元素越多,耗时越多
    if (_responderTextField && [_responderTextField isKindOfClass:[UITextField class]]) {
        return _responderTextField;
    }else {
        return nil;
    }
}

#pragma mark Override Super Method
- (void)dealloc{
    _numerPadArray = nil;
    _numerPadButtonArray = nil;
    
    [self removeObserverForFirstResponder];
    [self stopTimer];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.registerFirstResponderButton.frame = [self numberPadButtonFrameAtIndex:[_numerPadButtonArray count]];
    [self layoutNumberPadButton];
    [self addObserverForFirstResponder];
    
    if (self.disableSureButtonWhenTextFieldNoContent) {
        self.sureButton.enabled = [self textFieldHasContent];
    }
    
    CGRect rowOneLastButtonFrame = [self numberPadButtonFrameAtIndex:GJTCustomKeyboardNumberButtonCountEveryRow-1];
    CGFloat lineHeight = 1.0f/[[UIScreen mainScreen] scale];
    self.deleteButton.frame = CGRectMake(CGRectGetMaxX(rowOneLastButtonFrame)+lineHeight, GJTCustomKeyboardNumberContentInsets.top, GJTCustomKeyboardDeleteButtonWidth, 2*GJTCustomKeyboardNumberButtonHeight);
    self.sureButton.frame = CGRectMake(CGRectGetMinX(self.deleteButton.frame) , CGRectGetMaxY(self.deleteButton.frame), CGRectGetWidth(self.deleteButton.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.deleteButton.frame) - GJTCustomKeyboardNumberContentInsets.bottom - GJTBottomSafeMargin);
    
    if (isiPhoneX) {
        self.bottomSafeView.frame = CGRectMake(0, CGRectGetMaxY(self.sureButton.frame), CGRectGetWidth(self.bounds), GJTBottomSafeMargin);
        self.bottomLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.bottomSafeView.bounds), lineHeight);
    }
}

- (void)layoutNumberPadButton{
    for (NSInteger i = 0;i<[_numerPadButtonArray count];i++) {
        GJTBaseButton* numberButton = _numerPadButtonArray[i];
        numberButton.frame = [self numberPadButtonFrameAtIndex:i];
    }
}

- (CGRect)numberPadButtonFrameAtIndex:(NSInteger)index{
    CGSize  numberButtonSize = [self numberPadButtonSize];
    CGFloat lineHeight = 1.0f/[[UIScreen mainScreen] scale];
    CGPoint numberButtonPosition = CGPointMake((index%GJTCustomKeyboardNumberButtonCountEveryRow)*(numberButtonSize.width + lineHeight) + GJTCustomKeyboardNumberContentInsets.left, (index/GJTCustomKeyboardNumberButtonCountEveryRow)*(numberButtonSize.height + lineHeight) + GJTCustomKeyboardNumberContentInsets.top);
    return CGRectMake(numberButtonPosition.x, numberButtonPosition.y, numberButtonSize.width, numberButtonSize.height);
}

#pragma mark SubViews
- (GJTDeleteButton*)deleteButton{
    if (!_deleteButton) {
        UIImage *imgNormal      = [self buttonNomalBackgroundImage];
        UIImage *imgHighLighted = [self buttonHightlightBackgroundImage];
        _deleteButton = [[GJTDeleteButton alloc] initWithFrame:CGRectZero];
        [_deleteButton setImage:[UIImage imageNamed:@"GJTKeyboardDeleteButton"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.backgroundColor = [UIColor whiteColor];
        [_deleteButton setBackgroundImage:imgNormal forState:UIControlStateNormal];
        [_deleteButton setBackgroundImage:imgHighLighted forState:UIControlStateHighlighted];
        __weak typeof(self) block_self = self;
        _deleteButton.touchBlock = ^(GJTDeleteButton* button,GJTDeleteButtonTouchState state){
            switch (state) {
                case GJTDeleteButtonTouchStateBegan:
                    [block_self performSelector:@selector(startDeleteText) withObject:nil afterDelay:0.3];
                    break;
                case GJTDeleteButtonTouchStateCancelled:
                case GJTDeleteButtonTouchStateEnded:
                    [block_self stopTimer];
                    break;
                default:
                    break;
            }
        };
    }
    return _deleteButton;
}

- (GJTBaseButton*)registerFirstResponderButton{
    if (!_registerFirstResponderButton) {
        UIImage *imgNormal      = [self buttonNomalBackgroundImage];
        UIImage *imgHighLighted = [self buttonHightlightBackgroundImage];
        _registerFirstResponderButton = [[GJTBaseButton alloc] initWithFrame:CGRectZero];
        [_registerFirstResponderButton setImage:[UIImage imageNamed:@"GJTKeyboardHideButton"] forState:UIControlStateNormal];
        [_registerFirstResponderButton addTarget:self action:@selector(registerFirstResponderButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [_registerFirstResponderButton setBackgroundImage:imgNormal forState:UIControlStateNormal];
        [_registerFirstResponderButton setBackgroundImage:imgHighLighted forState:UIControlStateHighlighted];
    }
    return _registerFirstResponderButton;
}

- (GJTBaseButton*)sureButton{
    if (!_sureButton) {
        _sureButton = [[GJTBaseButton alloc] initWithFrame:CGRectZero];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setBackgroundImage:[self buttonImageFromColor:GJTColorForHex(@"#00aaee")] forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_sureButton setTitleColor:GJTColorForHex(@"#80d5f7") forState:UIControlStateDisabled];
        [_sureButton addTarget:self action:@selector(sureButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIView *)bottomSafeView {
    if (!_bottomSafeView) {
        _bottomSafeView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomSafeView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomSafeView;
}

- (CALayer *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [CALayer layer];
        _bottomLine.backgroundColor = self.backgroundColor.CGColor;
    }
    return _bottomLine;
}

#pragma mark Private-Method
- (BOOL)textFieldHasContent{
    UITextField* textField = [self currentResponderTextField];
    if (textField) {
       return textField.text.length;
    }else {
        return NO;
    }
}

- (void)fillNumberPadArrayWithType:(GJTCustomKeyboardType)type{
    
    if (!_numerPadButtonArray) {
        _numerPadButtonArray = [[NSMutableArray alloc] initWithCapacity:0];
    }else {
        [_numerPadButtonArray removeAllObjects];
    }
    
    _numerPadArray = nil;
    
    switch (type) {
        case GJTCustomKeyboardTypeNumberPad:
            _numerPadArray = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"",@"0", nil];
            break;
        case GJTCustomKeyboardTypeNumAndDotPad:
            _numerPadArray = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"0", nil];
            break;
        case GJTCustomKeyboardTypeNumAndXPad:
            _numerPadArray = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"X",@"0", nil];
            break;
        default:
            break;
    }
}

- (void)createNumberPadButtonWithType:(GJTCustomKeyboardType)type{
    [self fillNumberPadArrayWithType:type];
    
    UIImage *imgNormal      = [self buttonNomalBackgroundImage];
    UIImage *imgHighLighted = [self buttonHightlightBackgroundImage];
    for (NSInteger i = 0 ; i < [_numerPadArray count] ;i ++) {
        NSString* numberValue = _numerPadArray[i];
        GJTBaseButton* numberButton = [GJTBaseButton buttonWithType:UIButtonTypeCustom];
        [numberButton setTitle:numberValue forState:UIControlStateNormal];
        [numberButton addTarget:self action:@selector(numberPadButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        numberButton.tag = i;
        numberButton.backgroundColor = [UIColor whiteColor];
        [numberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        numberButton.titleLabel.font = [UIFont systemFontOfSize:25.0];
        [numberButton setBackgroundImage:imgNormal forState:UIControlStateNormal];
        [numberButton setBackgroundImage:imgHighLighted forState:UIControlStateHighlighted];
        [self addSubview:numberButton];
        [_numerPadButtonArray addObject:numberButton];
        numberButton.enabled = numberValue.length;
    }
}

/* 返回_textField的文本选择范围 */
- (NSRange)selectedRange
{
    UITextField* _responderTextField = [self currentResponderTextField];
    UITextPosition *beginning = _responderTextField.beginningOfDocument;
    UITextRange *selectedRange = _responderTextField.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    const NSInteger location = [_responderTextField offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [_responderTextField offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

- (void)numberPadButtonTaped:(GJTBaseButton*)sender{
    UITextField* _responderTextField = [self currentResponderTextField];
    if (!_responderTextField) {
        return;
    }
    
    /* 输入或者删除操作，主动调用textField:shouldChangeCharactersInRange:replacementString:方法，根据返回的值判断是否改变textfield的文本 */
    NSString *inputString = [NSString stringWithFormat:@"%@",_numerPadArray[sender.tag]];
    BOOL shouldChangeText = YES;
    if (_responderTextField.delegate && [_responderTextField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChangeText = [_responderTextField.delegate textField:_responderTextField shouldChangeCharactersInRange:[self selectedRange] replacementString:inputString];
    }
    if (shouldChangeText) {
        [_responderTextField insertText:inputString];
    }
    
    [self playClickSound];
    
}

- (void)deleteButtonTaped:(GJTBaseButton*)sender{
    [self deleteTextFieldText];
}

- (void)deleteTextFieldText{
    UITextField* _responderTextField = [self currentResponderTextField];
    if (!_responderTextField) {
        return;
    }

    NSRange selectedRange = [self selectedRange];
    if (selectedRange.length == 0) {
        if (selectedRange.location >= 1) {
            selectedRange = NSMakeRange(selectedRange.location - 1, 1);
        }
    }
//    BOOL shouldChangeText = YES; // 这段代码为选择替换而生
    if (_responderTextField.delegate && [_responderTextField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        [_responderTextField.delegate textField:_responderTextField shouldChangeCharactersInRange:selectedRange replacementString:@""];
    }
    
    if (_responderTextField.text.length) {
        [self playClickSound];
    }
    [_responderTextField deleteBackward];
}

- (void)registerFirstResponderButtonTaped:(GJTBaseButton*)sender{
    [self playClickSound];
    [self registerFirstResponder];
}

- (void)sureButtonTaped:(GJTBaseButton*)sender{
    [self playClickSound];
    [self registerFirstResponder];
}

- (void)registerFirstResponder{
    UITextField* _responderTextField = [self currentResponderTextField];
    if (!_responderTextField) {
        return;
    }
    /* 隐藏键盘，主动调用textFieldShouldReturn，根据返回值决定是否隐藏键盘 */
    BOOL shouldReturn = YES;
    if (_responderTextField.delegate && [_responderTextField.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        shouldReturn = [_responderTextField.delegate textFieldShouldReturn:_responderTextField];
    }
    if (shouldReturn) {
        [_responderTextField resignFirstResponder];
    }
}

/** 数字键盘的按钮尺寸 */
- (CGSize)numberPadButtonSize{
    CGFloat lineHeight = 1.0f/[[UIScreen mainScreen] scale];
    return  CGSizeMake(((CGRectGetWidth(self.bounds) - GJTCustomKeyboardDeleteButtonWidth) - GJTCustomKeyboardNumberContentInsets.left - GJTCustomKeyboardNumberContentInsets.right - (GJTCustomKeyboardNumberButtonCountEveryRow - 1)*lineHeight)/GJTCustomKeyboardNumberButtonCountEveryRow, GJTCustomKeyboardNumberButtonHeight);
}

- (UIResponder*)findFirstResponder{
    return [[[UIApplication sharedApplication] keyWindow] findFirstResponder];
}

- (UIColor *)numberPadButtonBorderColor{
    return GJTColorForHex(@"#cccccc");
}

- (UIImage *)buttonNomalBackgroundImage{
    return [self buttonImageFromColor:[UIColor whiteColor]];
}

- (UIImage *)buttonHightlightBackgroundImage{
    return [self buttonImageFromColor:[UIColor colorWithRed:209/255.0f green:214/255.0f blue:219/255.0f alpha:1]];
}

- (UIImage *)buttonImageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark 文本框内容变化监测
- (void)addObserverForFirstResponder{
    [self removeObserverForFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponsderTextValueChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)firstResponsderTextValueChanged:(NSNotification*)notification{
    UITextField* responder = [self currentResponderTextField];
    if (notification.object == responder) {
        if (self.disableSureButtonWhenTextFieldNoContent) {
            self.sureButton.enabled = responder.text.length;
        }
    }
}

- (void)removeObserverForFirstResponder{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark 对删除按钮添加类似系统键盘的长按删除功能
- (void)startDeleteText{
    if (!_deleteTimer) {
        _deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(deleteText) userInfo:nil repeats:YES];
    }
    [_deleteTimer fire];
}

- (void)stopTimer{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startDeleteText) object:nil];
    if (_deleteTimer) {
        [_deleteTimer invalidate];
        _deleteTimer = nil;
    }
}

- (void)deleteText{
    if ([self textFieldHasContent]) {
        [self deleteTextFieldText];
    }else {
        [self stopTimer];
    }
}

/** 播放键盘点击音效 */
- (void)playClickSound{
    [[UIDevice currentDevice] playInputClick];
}

#pragma mark UIInputViewAudioFeedback Protocal
/** 开启键盘点击音效播放功能 */
- (BOOL)enableInputClicksWhenVisible{
    return YES;
}

@end

@implementation GJTDeleteButton

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (self.touchBlock) {
        self.touchBlock(self,GJTDeleteButtonTouchStateBegan);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    if (self.touchBlock) {
        self.touchBlock(self,GJTDeleteButtonTouchStateCancelled);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (self.touchBlock) {
        self.touchBlock(self,GJTDeleteButtonTouchStateEnded);
    }
}

@end
