//
//  MDSpreadViewCell.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//  
//  Also, it'd be super awesome if you credited this page in your about screen :)
//  

#import "MDSpreadViewCell.h"
#import "MDSpreadView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface MDSpreadViewCellTapGestureRecognizer : UIGestureRecognizer {
    CGPoint touchDown;
}

@end

@implementation MDSpreadViewCellTapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
    touchDown = [[touches anyObject] locationInView:self.view.window];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint newPoint = [[touches anyObject] locationInView:self.view.window];
    if (fabs(touchDown.x - newPoint.x) > 5 || fabs(touchDown.y - newPoint.y) > 5) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end

@interface MDSpreadViewCell ()

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, unsafe_unretained) MDSpreadView *spreadView;
@property (nonatomic, strong) MDSortDescriptor *sortDescriptorPrototype;
@property (nonatomic) MDSpreadViewSortAxis defaultSortAxis;

@property (nonatomic, readonly) UIGestureRecognizer *_tapGesture;
@property (nonatomic, strong) MDIndexPath *_rowPath;
@property (nonatomic, strong) MDIndexPath *_columnPath;

@end

@interface MDSpreadView ()

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell;
- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell;
- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell;

@end

@implementation MDSpreadViewCell

@synthesize backgroundView, highlighted, highlightedBackgroundView, reuseIdentifier, textLabel, detailTextLabel, style, objectValue, _tapGesture, spreadView, sortDescriptorPrototype, defaultSortAxis, _rowPath, _columnPath;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"_MDDefaultCell"];
}

- (id)initWithStyle:(MDSpreadViewCellStyle)aStyle reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (!aReuseIdentifier) return nil;
    if (self = [super initWithFrame:CGRectZero]) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.reuseIdentifier = aReuseIdentifier;
        self.multipleTouchEnabled = YES;
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        style = aStyle;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewCell"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        self.backgroundView = imageView;
        
        imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MDSpreadViewCellSelected"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        self.highlightedBackgroundView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
		label.opaque = YES;
		label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18];
		label.highlightedTextColor = [UIColor blackColor];
        self.textLabel = label;
        
        label = [[UILabel alloc] init];
		label.opaque = YES;
		label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18];
		label.highlightedTextColor = [UIColor blackColor];
        self.detailTextLabel = label;
        
        _tapGesture = [[MDSpreadViewCellTapGestureRecognizer alloc] init];
        _tapGesture.cancelsTouchesInView = NO;
        _tapGesture.delaysTouchesEnded = NO;
        _tapGesture.delegate = self;
        [_tapGesture addTarget:self action:@selector(_handleTap:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)setReuseIdentifier:(NSString *)anIdentifier
{
    if (reuseIdentifier != anIdentifier) {
        reuseIdentifier = anIdentifier;
        
        _reuseHash = [reuseIdentifier hash];
    }
}

- (void)_handleTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _shouldCancelTouches = ![spreadView _touchesBeganInCell:self];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!_shouldCancelTouches)
            [spreadView _touchesEndedInCell:self];
        
        _shouldCancelTouches = NO;
    } else if (gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        if (!_shouldCancelTouches)
            [spreadView _touchesCancelledInCell:self];
        
        _shouldCancelTouches = NO;
    }
}

- (void)setBackgroundView:(UIView *)aBackgroundView
{
    [backgroundView removeFromSuperview];
    backgroundView = aBackgroundView;
    
    [self insertSubview:backgroundView atIndex:0];
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundView:(UIView *)aHighlightedBackgroundView
{
    [highlightedBackgroundView removeFromSuperview];
    highlightedBackgroundView = aHighlightedBackgroundView;
    
    if (highlighted) {
        highlightedBackgroundView.alpha = 1;
    } else {
        highlightedBackgroundView.alpha = 0;
    }
    [self insertSubview:highlightedBackgroundView aboveSubview:self.backgroundView];
    [self setNeedsLayout];
}

- (void)setTextLabel:(UILabel *)aTextLabel
{
    [textLabel removeFromSuperview];
    textLabel = aTextLabel;
    
    textLabel.highlighted = highlighted;
    [self addSubview:textLabel];
    [self setNeedsLayout];
}

- (void)setDetailTextLabel:(UILabel *)aTextLabel
{
    [detailTextLabel removeFromSuperview];
    detailTextLabel = aTextLabel;
    
    detailTextLabel.highlighted = highlighted;
    [self addSubview:detailTextLabel];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    backgroundView.frame = self.bounds;
    highlightedBackgroundView.frame = self.bounds;
    textLabel.frame = CGRectMake(10, 2, self.bounds.size.width-20, self.bounds.size.height-3);
}

- (void)setHighlighted:(BOOL)isHighlighted
{
    [self setHighlighted:isHighlighted animated:NO];
}

- (void)prepareForReuse
{
    self.highlighted = NO;
    self.objectValue = nil;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated
{
    if (highlighted != isHighlighted) {
        highlighted = isHighlighted;
        
        textLabel.opaque = !isHighlighted;
        detailTextLabel.opaque = !isHighlighted;
        if (highlighted) {
            textLabel.backgroundColor = [UIColor clearColor];
            detailTextLabel.backgroundColor = [UIColor clearColor];
        } else {
            textLabel.backgroundColor = [UIColor clearColor];
            detailTextLabel.backgroundColor = [UIColor clearColor];
        }
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                if (highlighted) {
                    highlightedBackgroundView.alpha = 1;
                } else {
                    highlightedBackgroundView.alpha = 0;
                }
                textLabel.highlighted = highlighted;
                detailTextLabel.highlighted = highlighted;
            }];
        } else {
            if (highlighted) {
                highlightedBackgroundView.alpha = 1;
            } else {
                highlightedBackgroundView.alpha = 0;
            }
            textLabel.highlighted = highlighted;
            detailTextLabel.highlighted = highlighted;
        }
    }
}

- (id)objectValue
{
    return self.textLabel.text;
}

- (void)setObjectValue:(id)anObject
{
    if (anObject != objectValue) {
        objectValue = anObject;
    
        if ([objectValue respondsToSelector:@selector(description)]) {
            self.textLabel.text = [objectValue description];
        }
    }
}

- (void)dealloc
{
    spreadView = nil;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (detailTextLabel.text) {
        return [NSString stringWithFormat:@"%@, %@", self.detailTextLabel.text, self.textLabel.text];
    }
    
    return textLabel.text;
}

- (NSString *)accessibilityHint
{
    return @"Double tap to show more information.";
}

- (UIAccessibilityTraits)accessibilityTraits
{
    if (self.highlighted) {
        return UIAccessibilityTraitSelected;
    }
    return UIAccessibilityTraitNone;
}

@end
