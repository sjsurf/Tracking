//
//  UITableView+Tracking.m
//  tracking_demo
//
//  Created by luguobin on 15/9/21.
//  Copyright © 2015年 XS. All rights reserved.
//

#import "UITableView+Tracking.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "SGAgent.h"
#import "YYPatientHomeViewController.h"
@implementation UITableView (Tracking)

+ (void)load
{

}

+ (void)changeAddTarget
{
        Class class = [self class];
    
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(cimc_setDelegate:);
    
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
        //交换实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)cimc_setDelegate:(id<UITableViewDelegate>)delegate
{
    [self cimc_setDelegate:delegate];
    
    Class class = [delegate class];
    
    if (class_addMethod(class, NSSelectorFromString(@"cimc_didSelectRowAtIndexPath"), (IMP)cimc_didSelectRowAtIndexPath, "v@:@@")) {
        Method dis_originalMethod = class_getInstanceMethod(class, NSSelectorFromString(@"cimc_didSelectRowAtIndexPath"));
        Method dis_swizzledMethod = class_getInstanceMethod(class, @selector(tableView:didSelectRowAtIndexPath:));
        
        //交换实现
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}

void cimc_didSelectRowAtIndexPath(id self, SEL _cmd, id tableView, id indexpath)
{
    
    NSIndexPath *path = indexpath;
    //此处添加你想统计的打点事件
    XLog(@"%ld",(long)path.row);
    if ([self isKindOfClass:[YYPatientHomeViewController class]] ) {
        
        if (path.row == 0) {
             [SGAgent sendEvent:@"home_star_click"];
        }
        [SGAgent sendEvent:@"home_list_click"];
    }
    SEL selector = NSSelectorFromString(@"cimc_didSelectRowAtIndexPath");
    ((void(*)(id, SEL,id, id))objc_msgSend)(self, selector, tableView, indexpath);
}

@end
