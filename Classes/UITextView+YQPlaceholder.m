//
//  UITextView+YQPlaceholder.m
//  YQPlaceholderTextView
//
//  Created by 王叶庆 on 15/12/6.
//  Copyright © 2015年 王叶庆. All rights reserved.
//

#import "UITextView+YQPlaceholder.h"
#import <objc/runtime.h>

#define YQ_Default_Padding 7.0f

@implementation UITextView (YQPlaceholder)
@dynamic yq_placeholder,yq_placeholderColor,yq_placeholderLeftPadding,yq_placeholderTopPadding;

- (CGFloat)yq_placeholderLeftPadding{
    id padding = objc_getAssociatedObject(self, _cmd);
    return padding ? [padding doubleValue] : YQ_Default_Padding;
}
- (CGFloat)yq_placeholderTopPadding{
    id padding = objc_getAssociatedObject(self, _cmd);
    return padding ? [padding doubleValue] : YQ_Default_Padding;
}
- (void)setYq_placeholderLeftPadding:(CGFloat)yq_placeholderLeftPadding{
    objc_setAssociatedObject(self, @selector(yq_placeholderLeftPadding), @(yq_placeholderLeftPadding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)setYq_placeholderTopPadding:(CGFloat)yq_placeholderTopPadding{
    objc_setAssociatedObject(self, @selector(yq_placeholderTopPadding), @(yq_placeholderTopPadding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)yq_placeholderColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setYq_placeholderColor:(UIColor *)yq_placeholderColor{
    if([self yq_placeholderLabel]){
        [self yq_placeholderLabel].textColor = yq_placeholderColor;
    }
    objc_setAssociatedObject(self, @selector(yq_placeholderColor), yq_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)yq_placeholder{
    return [self yq_placeholderLabel].text;
}
- (void)setYq_placeholder:(NSString *)placeholder{
    if(self.delegate){//动态添加方法
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self.delegate class];
            Class swizzleClass = [self class];
            SEL originalSelector = @selector(textViewDidChange:);
            SEL swizzledSelector = @selector(yq_textViewDidChange:);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(swizzleClass, swizzledSelector);
            
            if(class_addMethod(class, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))){
                BOOL didAddMethod =
                class_addMethod(class,
                                originalSelector,
                                method_getImplementation(swizzledMethod),
                                method_getTypeEncoding(swizzledMethod));
                
                if (didAddMethod) {
                    //@"添加了，原来没有" //这时候就要替换刚才添加的方法实现
                    Method newSwizzledMethod = class_getInstanceMethod(swizzleClass, originalSelector);
                    class_replaceMethod(class,
                                        originalSelector,
                                        method_getImplementation(newSwizzledMethod),
                                        method_getTypeEncoding(newSwizzledMethod));
                } else {
                    //"没有添加 原来已经有了" //交换方法实现
                    Method newSwizzledMethod = class_getInstanceMethod(class, swizzledSelector);
                    method_exchangeImplementations(originalMethod, newSwizzledMethod);
                }
                
            }
            
        });
        
    }else{
        self.delegate = self;
    }
    UILabel *pl = [self yq_placeholderLabel];
    if(!pl){
        pl = [[UILabel alloc] init];
        pl.text = placeholder;
        pl.font = self.font;
        pl.textColor = self.yq_placeholderColor ? :[UIColor lightGrayColor];
        pl.frame = CGRectMake(self.yq_placeholderLeftPadding, self.yq_placeholderTopPadding, 10, 10);
        [self addSubview:pl];
        [self setYq_placeholderLabel:pl];
    }
    [pl sizeToFit];
    //    [pl sizeThatFits:CGSizeMake(self.bounds.size.width-self.contentInset.left-self.contentInset.right-self.textContainerInset.left-self.textContainerInset.right, 1000)];//自动布局的情况下，bounds完全有可能是0所以
}
- (UILabel *)yq_placeholderLabel{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setYq_placeholderLabel:(UILabel *)label{
    objc_setAssociatedObject(self, @selector(yq_placeholderLabel), label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark swizzle
- (void)yq_textViewDidChange:(UITextView *)textView{
    [self yq_textViewDidChange:textView];
    [textView yq_placeholderLabel].hidden = textView.text.length > 0;
}
- (void)textViewDidChange:(UITextView *)textView{
    [textView yq_placeholderLabel].hidden = textView.text.length > 0;
}
@end
