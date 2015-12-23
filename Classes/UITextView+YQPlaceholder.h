//
//  UITextView+YQPlaceholder.h
//  YQPlaceholderTextView
//
//  Created by 王叶庆 on 15/12/6.
//  Copyright © 2015年 王叶庆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (YQPlaceholder)<UITextViewDelegate>

@property (nonatomic, strong) IBInspectable NSString *yq_placeholder;
@property (nonatomic, strong) IBInspectable UIColor *yq_placeholderColor;

/**placeholder左边留白 默认7*/
@property (nonatomic, assign) CGFloat yq_placeholderLeftPadding;
/**placeholder上边留白 默认7*/
@property (nonatomic, assign) CGFloat yq_placeholderTopPadding;
@end
