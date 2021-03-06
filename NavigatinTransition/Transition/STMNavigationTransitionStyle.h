//
//  STMNavigationTransitionStyle.h
//  StromFacilitate
//
//  Created by WuYikai on 16/7/21.
//  Copyright © 2016年 DouKing. All rights reserved.
//

#ifndef STMNavigationTransitionStyle_h
#define STMNavigationTransitionStyle_h

typedef NS_ENUM(NSInteger, STMNavigationTransitionStyle) {
  STMNavigationTransitionStyleSystem,
  STMNavigationTransitionStyleResignLeft,
  STMNavigationTransitionStyleResignBottom,
  STMNavigationTransitionStyleNone = NSIntegerMax //only used by UIViewController
};

#endif /* STMNavigationTransitionStyle_h */
