//
//  Created by Devin Doty on 10/14/09.
//  http://github.com/enormego/EGOTableViewPullRefresh
//  Copyright 2009 enormego. All rights reserved.
//
//  Modifications copyright 2010 Facebook.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "Three20UI/TTTableHeaderDragRefreshView.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet+DragRefreshHeader.h"

// Network
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTGlobalCoreLocale.h"
#import "Three20Core/TTCorePreprocessorMacros.h"

#import <QuartzCore/QuartzCore.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableHeaderDragRefreshView


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
  if (shouldShow) {
    [_activityView startAnimating];

  } else {
    [_activityView stopAnimating];
  }

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:(animated ? ttkDefaultFastTransitionDuration : 0.0)];
  _arrowImage.alpha = (shouldShow ? 0.0 : 1.0);
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImageFlipped:(BOOL)flipped {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
  [_arrowImage layer].transform = (flipped ?
                                   CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f) :
                                   CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f));
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _lastUpdatedLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f,
                                                  frame.size.width, 20.0f)];
    _lastUpdatedLabel.autoresizingMask =
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _lastUpdatedLabel.font            = TTSTYLEVAR(tableRefreshHeaderLastUpdatedFont);
    _lastUpdatedLabel.textColor       = TTSTYLEVAR(tableRefreshHeaderTextColor);
    _lastUpdatedLabel.shadowColor     = TTSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _lastUpdatedLabel.shadowOffset    = TTSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    _lastUpdatedLabel.textAlignment   = UITextAlignmentCenter;
      
      // 为解决第一次加入时不显示的问题，我放了一段代码在这里   ->右边的waring是SX
      // initWithFrame最开始会进来两次，第二次会把已经初始化过的_lastUpdatedLabel覆盖
      // 所以这里干脆强行写text
      // 虽然丑了点，但也算是解决了，将就着用吧，人家官方新浪微博的客户端还没都没能解决这个问题呢！
      NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy年MM月dd日 hh:mm"];
      NSString* st = [formatter stringFromDate:[NSDate date]];
      _lastUpdatedLabel.text = [NSString stringWithFormat:
                                @"上次更新: %@", st];

    [self addSubview:_lastUpdatedLabel];

    _statusLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f,
                                             frame.size.width, 20.0f )];
    _statusLabel.autoresizingMask =
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _statusLabel.font             = TTSTYLEVAR(tableRefreshHeaderStatusFont);
    _statusLabel.textColor        = TTSTYLEVAR(tableRefreshHeaderTextColor);
    _statusLabel.shadowColor      = TTSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _statusLabel.shadowOffset     = TTSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    _statusLabel.backgroundColor  = [UIColor clearColor];
    _statusLabel.textAlignment    = UITextAlignmentCenter;
    [self setStatus:TTTableHeaderDragRefreshPullToReload];
    [self addSubview:_statusLabel];

    UIImage* arrowImage = TTSTYLEVAR(tableRefreshHeaderArrowImage);
    _arrowImage = [[UIImageView alloc]
                   initWithFrame:CGRectMake(25.0f, frame.size.height - 60.0f,
                                            arrowImage.size.width, arrowImage.size.height)];
    _arrowImage.image             = arrowImage;
    [_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    [self addSubview:_arrowImage];

    _activityView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake( 30.0f, frame.size.height - 38.0f, 20.0f, 20.0f );
    _activityView.hidesWhenStopped  = YES;
    [self addSubview:_activityView];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_activityView);
  TT_RELEASE_SAFELY(_statusLabel);
  TT_RELEASE_SAFELY(_arrowImage);
  TT_RELEASE_SAFELY(_lastUpdatedLabel);
  TT_RELEASE_SAFELY(_lastUpdatedDate);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUpdateDate:(NSDate*)newDate {
  if (newDate) {
    if (_lastUpdatedDate != newDate) {
      [_lastUpdatedDate release];
    }

    _lastUpdatedDate = [newDate retain];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 hh:mm"];
      NSString* st = [formatter stringFromDate:[NSDate date]];
    _lastUpdatedLabel.text = [NSString stringWithFormat:
                              @"上次更新: %@", st];
//      [_lastUpdatedLabel reloadInputViews];
    [formatter release];

  } else {
    _lastUpdatedDate = nil;
    _lastUpdatedLabel.text = TTLocalizedString(@"Last updated: never",
                                               @"The table view has never been updated");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentDate {
  [self setUpdateDate:[NSDate date]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatus:(TTTableHeaderDragRefreshStatus)status {
  switch (status) {
    case TTTableHeaderDragRefreshReleaseToReload: {
      [self showActivity:NO animated:NO];
      [self setImageFlipped:YES];
      _statusLabel.text = @"好啦，快松开啦！";
                                            
      break;
    }

    case TTTableHeaderDragRefreshPullToReload: {
      [self showActivity:NO animated:NO];
      [self setImageFlipped:NO];
      _statusLabel.text = @"下拉以更新";
      break;
    }

    case TTTableHeaderDragRefreshLoading: {
      [self showActivity:YES animated:YES];
      [self setImageFlipped:NO];
      _statusLabel.text = @"少女更新中...";
      break;
    }

    default: {
      break;
    }
  }
}

@end
