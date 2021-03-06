//
//  UIControl+Tracking.m
//  tracking_demo
//
//  Created by luguobin on 15/9/21.
//  Copyright © 2015年 XS. All rights reserved.
//

/**
 * 用来统计点击事件，，
 */

#import "UIControl+Tracking.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "SGAgent.h"
#import "YYPatientHomeViewController.h"
@implementation UIControl (Tracking)


+ (void)load
{
//    [self changeAddTarget];
}


+ (void)changeAddTarget
{
    Class class = [self class];
    
    SEL originalSelector = @selector(addTarget:action:forControlEvents:);
    SEL swizzledSelector = @selector(xs_addTarget:action:forControlEvents:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    //交换实现
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


- (void)xs_addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self xs_addTarget:target action:action forControlEvents:controlEvents];
    
    Class class = [target class];
    
    NSString *oldSelString = NSStringFromSelector(action);
    // 防止出现反复交换的问题
    if ([oldSelString rangeOfString:@"deer_"].location != NSNotFound) {
        return;
    }
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"deer_%@",oldSelString]);
    SEL actionSel = action;
    
    //types defined in https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html

    if (class_addMethod(class, selector, (IMP)xs_buttonAction, "v@:@")) {
        Method dis_originalMethod = class_getInstanceMethod(class, actionSel);
        Method dis_swizzledMethod = class_getInstanceMethod(class, selector);
        
        //交换实现
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}

/**
 * control点击事件最后的实现，可以拼接[self class]和事件方法弄个字符串，建个配置表
 *
 * @param self   target，一般为所在ViewController
 * @param _cmd   事件方法，点击的事件方法
 * @param sender sender，点击的button
 */
void  xs_buttonAction(id self, SEL _cmd, id sender) {

    //此处添加你想统计的打点事件
    NSString *oldSelString = NSStringFromSelector(_cmd);
    
    // 首页统计
    if ([self isKindOfClass:[YYPatientHomeViewController class]] ) {
        if ([oldSelString isEqualToString:@"search"]) {
            [SGAgent sendEvent:@"home_search_click"];
        }
    }
    
  
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"deer_%@",oldSelString]);
    ((void(*)(id, SEL,id))objc_msgSend)(self, selector, sender);
     
//    XLog(@"--------%@----%@--%@-",oldSelString,sender,[self class]);
}
@end
