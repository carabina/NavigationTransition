//
//  STMResignLeftTransitionAnimator.m
//  StromFacilitate
//
//  Created by WuYikai on 16/7/25.
//  Copyright © 2016年 secoo. All rights reserved.
//

#import "STMNavigationResignLeftTransitionAnimator.h"
#import "STMTransitionSnapshot.h"

static NSInteger const kSTMSnapshotViewTag = 19999;

@interface STMNavigationResignLeftTransitionAnimator ()

@property (nonatomic, strong) NSMutableArray<STMTransitionSnapshot *> *cachedSnapShotViews;

@end

@implementation STMNavigationResignLeftTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.35;
}

- (void)pushAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIView *containerView = [transitionContext containerView];
  UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

  UIView *maskView = [[UIView alloc] initWithFrame:containerView.bounds];
  maskView.backgroundColor = [UIColor blackColor];

  UIView *snapShotView = [self snapViewFromView:keyWindow];
  snapShotView.frame = maskView.bounds;
  snapShotView.tag = kSTMSnapshotViewTag;
  [maskView addSubview:snapShotView];

  [containerView addSubview:maskView];
  [containerView addSubview:toViewController.view];
  toViewController.view.transform = CGAffineTransformMakeTranslation(containerView.bounds.size.width, 0);
  toViewController.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(containerView.bounds.size.width, 0);

  if (toViewController.hidesBottomBarWhenPushed) {
    fromViewController.tabBarController.tabBar.alpha = 0;
  } else {
    fromViewController.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(containerView.bounds.size.width, 0);
  }
  [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
    toViewController.view.transform = CGAffineTransformIdentity;
    toViewController.navigationController.navigationBar.transform = CGAffineTransformIdentity;
    if (!toViewController.hidesBottomBarWhenPushed) {
      toViewController.tabBarController.tabBar.transform = CGAffineTransformIdentity;
    }
    snapShotView.transform = CGAffineTransformMakeScale(0.95, 0.95);
  } completion:^(BOOL finished) {
    STMTransitionSnapshot *snapshot = [[STMTransitionSnapshot alloc] init];
    snapshot.snapshotView = maskView;
    snapshot.viewController = fromViewController;
    [self.cachedSnapShotViews addObject:snapshot];

    [maskView removeFromSuperview];
    fromViewController.tabBarController.tabBar.alpha = 1;
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
  }];
}

- (void)popAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIView *containerView = [transitionContext containerView];
  UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

  STMTransitionSnapshot *cachedSnapshot = nil;
  UIView *cachedView = nil;
  for (STMTransitionSnapshot *snapshot in self.cachedSnapShotViews) {
    if ([snapshot.viewController isEqual:toViewController]) {
      cachedSnapshot = snapshot;
      cachedView = snapshot.snapshotView;
      cachedView.frame = keyWindow.bounds;
      break;
    }
  }
  if (cachedView) {
    [containerView addSubview:cachedView];
    [containerView addSubview:fromViewController.view];
    toViewController.tabBarController.tabBar.alpha = 0;
    UIView *tabBar = nil;
    if (fromViewController.tabBarController.tabBar && !fromViewController.hidesBottomBarWhenPushed) {
      tabBar = [keyWindow snapshotViewAfterScreenUpdates:NO];
      tabBar.frame = fromViewController.view.bounds;
      [fromViewController.view addSubview:tabBar];
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
      fromViewController.view.transform = CGAffineTransformMakeTranslation(containerView.bounds.size.width, 0);
      fromViewController.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(containerView.bounds.size.width, 0);
      [cachedView viewWithTag:kSTMSnapshotViewTag].transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      toViewController.navigationController.navigationBar.transform = CGAffineTransformIdentity;
      toViewController.tabBarController.tabBar.alpha = 1;
      [cachedView removeFromSuperview];
      [tabBar removeFromSuperview];
      if (![transitionContext transitionWasCancelled]) {
        [self.cachedSnapShotViews removeObject:cachedSnapshot];
      }
      [containerView addSubview:toViewController.view];
      [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
  } else {
    [super popAnimateTransition:transitionContext];
  }
}

#pragma mark -

// iOS10 上系统截图方法失效，以此替代
- (UIView *)snapViewFromView:(UIView *)originalView {
  @autoreleasepool {
    UIView *snapView = [originalView snapshotViewAfterScreenUpdates:NO];
    if (snapView) {
      return snapView;
    }

    UIGraphicsBeginImageContext(originalView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [originalView.layer renderInContext:context];
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [[UIImageView alloc] initWithImage:targetImage];
  }
}

- (NSMutableArray<STMTransitionSnapshot *> *)cachedSnapShotViews {
  if (!_cachedSnapShotViews) {
    _cachedSnapShotViews = [NSMutableArray array];
  }
  return _cachedSnapShotViews;
}

@end
