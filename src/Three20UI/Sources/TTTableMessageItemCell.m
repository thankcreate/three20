//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
#pragma GCC diagnostic warning "-Wformat"
#pragma GCC diagnostic error "-Wformat"
#pragma GCC diagnostic ignored "-Wformat"

#pragma GCC diagnostic ignored "-Wwarning-flag"
#import "Three20UI/TTTableMessageItemCell.h"

// UI
#import "Three20UI/TTImageView.h"
#import "Three20UI/TTTableMessageItem.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20Style/UIFontAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/NSDateAdditions.h"

#import "Three20Style/TTSolidBorderStyle.h"
#import "Three20Style/TTShapeStyle.h"
#import "Three20Style/TTRoundedRectangleShape.h"
#import "Three20Style/TTContentStyle.h"
#import "Three20Style/TTSpeechBubbleShape.h"
#import "Three20Style/TTSolidFillStyle.h"
// 下面这一行我现在不管了
static const NSInteger  kMessageTextLineCount       = 3;
static const CGFloat    kDefaultMessageImageWidth   = 34.0f;
static const CGFloat    kDefaultMessageImageHeight  = 34.0f;


#define EXIST 10
#define NOT_EXIST 11
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableMessageItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    if (self) {
        self.textLabel.font = TTSTYLEVAR(font);
        self.textLabel.textColor = TTSTYLEVAR(textColor);
        self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
        self.textLabel.backgroundColor = TTSTYLEVAR(backgroundTextColor);
        self.textLabel.textAlignment = UITextAlignmentLeft;
        self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.contentMode = UIViewContentModeTopLeft;
        
        self.detailTextLabel.font = TTSTYLEVAR(font);
        self.detailTextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
        self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
        self.detailTextLabel.backgroundColor = TTSTYLEVAR(backgroundTextColor);
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.detailTextLabel.contentMode = UIViewContentModeTopLeft;
        self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.detailTextLabel.numberOfLines = 100;
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    TT_RELEASE_SAFELY(_titleLabel);
    TT_RELEASE_SAFELY(_timestampLabel);
    TT_RELEASE_SAFELY(_iconImage);
    TT_RELEASE_SAFELY(_thumbImage);
    TT_RELEASE_SAFELY(_forwardView);
    TT_RELEASE_SAFELY(_forwardTitleLabel);
    TT_RELEASE_SAFELY(_forwardThumbImage);
    TT_RELEASE_SAFELY(_forwardTextLabel);
    TT_RELEASE_SAFELY(_fromLabel);
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    // XXXjoe Compute height based on font sizes
    TTTableMessageItem* item = object;
    CGFloat height = TTSTYLEVAR(tableFont).ttLineHeight + kTableCellVPadding*1.5;
    if (item.caption)
    {
        height += TTSTYLEVAR(font).ttLineHeight;
    }
    if (item.text)
    {
        UIFont *myTextFont = TTSTYLEVAR(font);
        CGSize maximumLabelSize = CGSizeMake(274,9999);
        CGSize linesSize = [item.text sizeWithFont:myTextFont
                                 constrainedToSize:maximumLabelSize
                                     lineBreakMode:UILineBreakModeWordWrap];
        height += linesSize.height;
    }
    if(item.thumbImageURL)
    {
        height += 80;
    }
    // 针对有转发的情况
    if(item.forwardItem)
    {
        // 转发部分不要标题了，与转发正文合并显示
        if (item.forwardItem.title.length)
        {
            height += TTSTYLEVAR(font).ttLineHeight;
        }
        if (item.forwardItem.text)
        {
            UIFont *myTextFont = TTSTYLEVAR(tableTimestampFont);
            CGSize maximumLabelSize = CGSizeMake(274,9999);
            CGSize linesSize = [item.forwardItem.text sizeWithFont:myTextFont
                                                 constrainedToSize:maximumLabelSize
                                                     lineBreakMode:UILineBreakModeWordWrap];
            height += linesSize.height;
        }
        if(item.forwardItem.thumbImageURL)
        {
            height += 80;
        }
        height += 18;
    }
    if (item.from)
    {
        height += TTSTYLEVAR(font).ttLineHeight;
    }
    if (item.imageURL)
    {
        height = height > kDefaultMessageImageHeight ? height : kDefaultMessageImageHeight;
    }
    return height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
    [super prepareForReuse];
    [_iconImage unsetImage];
    [_thumbImage unsetImage];
    // _thumbImage.urlPath = nil;
    //_forwardView.tag = NOT_EXIST;
    _titleLabel.text = nil;
    _timestampLabel.text = nil;
    
    _forwardView.tag = 0;
    _forwardTextLabel.text = nil;
    _forwardTitleLabel.text = nil;
    _fromLabel.text = nil;
    [_forwardThumbImage unsetImage];
    self.captionLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    @synchronized(self){
        CGFloat left = 0.0f;
        // 1 左侧是一个头像
        if (_iconImage) {
            _iconImage.frame = CGRectMake(kTableCellSmallMargin, kTableCellSmallMargin,
                                          kDefaultMessageImageWidth, kDefaultMessageImageHeight);
            left += kTableCellSmallMargin + kDefaultMessageImageHeight + kTableCellSmallMargin;
        }
        else
        {
            left = kTableCellMargin;
        }
        // 2 开始右侧部分
        CGFloat width = self.contentView.width - left; // 右侧的总宽度
        CGFloat top = kTableCellSmallMargin;
        // 2.1 标题，目前就是状态来源的昵称 转发部分不要标题了，与2.4.2合并显示
        if (_titleLabel.text.length) {
            _titleLabel.frame = CGRectMake(left, top, width, _titleLabel.font.ttLineHeight);
            top += _titleLabel.height;
        }
        else
        {
            _titleLabel.frame = CGRectZero;
        }
        // 2.2 正文
        if (self.detailTextLabel.text.length) {
            CGSize maximumLabelSize = CGSizeMake(width,9999);
            CGSize expectedLabelSize = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font
                                                             constrainedToSize:maximumLabelSize
                                                                 lineBreakMode:self.detailTextLabel.lineBreakMode];
            self.detailTextLabel.frame = CGRectMake(left, top, width, expectedLabelSize.height);
            top += expectedLabelSize.height;
        }
        else
        {
            self.detailTextLabel.frame = CGRectZero;
        }
        // 2.3 正文附图
        if(_thumbImage.urlPath != nil)
        {
            self.thumbImage.frame = CGRectMake(left, top + 5, 75, 75);
            self.thumbImage.contentMode = UIViewContentModeScaleAspectFit;
            // TTSolidBorderStyle* st = [TTSolidBorderStyle styleWithColor:[UIColor blackColor]
            //                                                       width:4
            //                                                       next:nil];
            // [self.thumbImage.style addStyle:st];
            // self.thumbImage.backgroundColor = [UIColor blackColor];
            //        self.thumbImage.style =   [TTShapeStyle styleWithShape: st];
            top += 80;
        }
        else
        {
            self.thumbImage.frame = CGRectZero;
        }
        // 2.4 转发部分
        if( _forwardView.tag == EXIST )
        {
            CGFloat forwardWidth = width - 25;
            CGFloat forwardLeft = left + 7;

            _forwardView.frame = CGRectMake(left, top, width-10, 200);
            UIColor* black = RGBCOLOR(158, 163, 172);
            TTStyle* style = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5
                                                                                 pointLocation:60
                                                                                    pointAngle:90
                                                                                     pointSize:CGSizeMake(10,5)] next:
                              [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
                               [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
            _forwardView.backgroundColor = [UIColor whiteColor];
            _forwardView.style = style;
            
            top+= 10;
            // 2.4.1 转发部分标题
            if (_forwardTitleLabel.text.length)
            {
                _forwardTitleLabel.frame = CGRectMake(forwardLeft, top, forwardWidth, _forwardTitleLabel.font.ttLineHeight);
                top += _forwardTitleLabel.height;
            }
            else
            {
                _forwardTitleLabel.frame = CGRectZero;
            }
            // 2.4.2 转发部分正文
            if (_forwardTextLabel.text.length) {
                CGSize maximumLabelSize = CGSizeMake(width,9999);
                CGSize expectedLabelSize = [_forwardTextLabel.text sizeWithFont:_forwardTextLabel.font
                                                              constrainedToSize:maximumLabelSize
                                                                  lineBreakMode:_forwardTextLabel.lineBreakMode];
                _forwardTextLabel.frame = CGRectMake(forwardLeft, top, forwardWidth, expectedLabelSize.height);
                top += expectedLabelSize.height;
            }
            else
            {
                _forwardTextLabel.frame = CGRectZero;
            }
            // 2.4.3 转发部分图片
            if(_forwardThumbImage.urlPath != nil)
            {
                self.forwardThumbImage.frame = CGRectMake(forwardLeft, top + 5, 75, 75);
                self.forwardThumbImage.contentMode = UIViewContentModeScaleAspectFit;
                top += 80;
            }
            else
            {
                self.forwardThumbImage.frame = CGRectZero;
            }
            
            CGRect rec = _forwardView.frame;
            CGFloat newHeight = _forwardTitleLabel.frame.size.height
                + _forwardTextLabel.frame.size.height
                + _forwardThumbImage.frame.size.height
                + 18;
            _forwardView.frame = CGRectMake(rec.origin.x, rec.origin.y, rec.size.width, newHeight);
        }
        else
        {
            _forwardView.frame = CGRectZero;
            _forwardTitleLabel.frame = CGRectZero;
            _forwardTextLabel.frame = CGRectZero;
            _forwardThumbImage.frame = CGRectZero;
        }
        
        // 2.5.1 信息来源
        if (_fromLabel.text.length) {
            top += 3;
            if( _forwardView.tag == EXIST )
            {
                top += 8;
            }

            CGSize maximumLabelSize = CGSizeMake(width,9999);
            CGSize expectedLabelSize = [_fromLabel.text sizeWithFont:_fromLabel.font
                                                          constrainedToSize:maximumLabelSize
                                                              lineBreakMode:_fromLabel.lineBreakMode];
            _fromLabel.frame = CGRectMake(left, top, expectedLabelSize.width, expectedLabelSize.height);
            top += expectedLabelSize.height;
        }
        else
        {
            _fromLabel.frame = CGRectZero;
        }
        
        // 2.5.2 时间
        if (_timestampLabel.text.length)
        {
            _timestampLabel.alpha = !self.showingDeleteConfirmation;
            [_timestampLabel sizeToFit];
            _timestampLabel.left = self.contentView.width -
            (_timestampLabel.width + kTableCellSmallMargin);
            _timestampLabel.top = _fromLabel.top;
            _titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;
        }
        else
        {
            _timestampLabel.frame = CGRectZero;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        _iconImage.backgroundColor = self.backgroundColor;
        _thumbImage.backgroundColor = self.backgroundColor;
        _titleLabel.backgroundColor = self.backgroundColor;
        _timestampLabel.backgroundColor = self.backgroundColor;
        _forwardView.backgroundColor =  self.backgroundColor;
        _forwardTitleLabel.backgroundColor = self.backgroundColor;
        _forwardTextLabel.backgroundColor = self.backgroundColor;
        _forwardThumbImage.backgroundColor = self.backgroundColor;
        _fromLabel.backgroundColor = self.backgroundColor;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    if (_item != object) {
        [super setObject:object];
        TTTableMessageItem* item = object;
        if (item.title.length) {
            self.titleLabel.text = item.title;
        }
        if (item.caption.length) {
            self.captionLabel.text = item.caption;
        }
        if (item.text.length) {
            self.detailTextLabel.text = item.text;
        }
        if (item.timestamp) {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];        
            [formatter setDateFormat:@"MM-dd HH:mm"];
            NSString* strTime = [formatter stringFromDate:item.timestamp];
            self.timestampLabel.text = strTime;
        }
        if (item.imageURL.length) {
            self.iconImage.urlPath = item.imageURL;
        }
        if (item.thumbImageURL) {
            self.thumbImage.urlPath = item.thumbImageURL;
        }
        if (item.from.length) {
            self.fromLabel.text = item.from;
        }
        if (item.forwardItem){
            self.forwardView.tag = EXIST;
            if( item.forwardItem.title.length )
            {
                self.forwardTitleLabel.text = item.forwardItem.title;
            }
            if(item.forwardItem.text.length)
            {
                self.forwardTextLabel.text = item.forwardItem.text;
            }
            if(item.forwardItem.thumbImageURL.length)
            {
                self.forwardThumbImage.urlPath = item.forwardItem.thumbImageURL;
            }
        }
        
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        _titleLabel.font = TTSTYLEVAR(tableFont);
        _titleLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
    return self.textLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.font = TTSTYLEVAR(tableTimestampFont);
        _timestampLabel.textColor = TTSTYLEVAR(timestampTextColor);
        _timestampLabel.highlightedTextColor = [UIColor whiteColor];
        _timestampLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_timestampLabel];
    }
    return _timestampLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTImageView*)iconImage {
    if (!_iconImage) {
        _iconImage = [[TTImageView alloc] init];
        //    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
        //_iconImage.style = TTSTYLE(rounded);
        [self.contentView addSubview:_iconImage];
    }
    return _iconImage;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTImageView*)thumbImage {
    if (!_thumbImage) {
        _thumbImage = [[TTImageView alloc] init];
        //    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
        //_thumbImage.style = TTSTYLE(rounded);
        [self.contentView addSubview:_thumbImage];
    }
    return _thumbImage;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTImageView*)forwardThumbImage {
    if (!_forwardThumbImage) {
        _forwardThumbImage = [[TTImageView alloc] init];
        //    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
        //_thumbImage.style = TTSTYLE(rounded);
        [self.contentView addSubview:_forwardThumbImage];
    }
    return _forwardThumbImage;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)forwardTitleLabel {
    if (!_forwardTitleLabel) {
        _forwardTitleLabel = [[UILabel alloc] init];
        _forwardTitleLabel.textColor = TTSTYLEVAR(tableSubTextColor);
        _forwardTitleLabel.highlightedTextColor = [UIColor whiteColor];
        _forwardTitleLabel.font = TTSTYLEVAR(font);
        _forwardTitleLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_forwardTitleLabel];
    }
    return _forwardTitleLabel;
}

- (UILabel*)forwardTextLabel {
    if (!_forwardTextLabel) {
        _forwardTextLabel = [[UILabel alloc] init];
        _forwardTextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
        _forwardTextLabel.highlightedTextColor = [UIColor whiteColor];
        _forwardTextLabel.font = TTSTYLEVAR(tableTimestampFont);
        _forwardTextLabel.contentMode = UIViewContentModeLeft;
        _forwardTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _forwardTextLabel.numberOfLines = 100;        

        [self.contentView addSubview:_forwardTextLabel];
    }
    return _forwardTextLabel;
}

- (UILabel*)fromLabel {
    if (!_fromLabel) {
        _fromLabel = [[UILabel alloc] init];
        _fromLabel.textColor = TTSTYLEVAR(timestampTextColor);
        _fromLabel.highlightedTextColor = [UIColor whiteColor];
        _fromLabel.font = TTSTYLEVAR(font);
        _fromLabel.contentMode = UIViewContentModeLeft;
        _fromLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _fromLabel.numberOfLines = 100;        
        [self.contentView addSubview:_fromLabel];
    }
    return _fromLabel;
}

- (TTView*)forwardView {
    if (!_forwardView) {
        _forwardView = [[TTView alloc] init];
        //    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
        //_thumbImage.style = TTSTYLE(rounded);
        [self.contentView addSubview:_forwardView];
    }
    return _forwardView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)rounded {
    return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:1] next:
     //[TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:4 next:
     [TTContentStyle styleWithNext:nil]];
}
#pragma warning restore
@end
