//  APLTextView.h
//
//  Created by Michael Kamphausen on 11.09.14.
//  Copyright (c) 2014 apploft GmbH. All rights reserved.
//

#import "APLTextView.h"

@interface APLTextView ()

@property (nonatomic, strong) UIImageView* backgroundView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *counterLabel;

@end

@implementation APLTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)commonInit {
    if (self) {
        self.scrollEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.frame.size.width, self.frame.size.height)];
        UIImage *backgroundImage = [[UIImage imageNamed:@"background-textfield"] resizableImageWithCapInsets:UIEdgeInsetsMake(5., 10., 5., 10.)];
        self.backgroundView.image = backgroundImage;
        self.scrollsToTop = NO;
        
        self.placeholderLabel = [UILabel new];
        self.placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.placeholderLabel.numberOfLines = 0;
        self.placeholderLabel.tag = 999;
        
        self.counterLabel = [UILabel new];
        self.counterLabel.tag = 998;
        self.counterLabel.textAlignment = NSTextAlignmentRight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hasCounter {
    return self.maxCharacters > 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = CGRectMake(0., self.contentOffset.y, self.frame.size.width, self.frame.size.height);
    if (!self.backgroundView.superview) {
        [self addSubview:self.backgroundView];
    }
    [self sendSubviewToBack:self.backgroundView];
    
    CGFloat leftMargin = 8.;
    CGFloat topMargin = 0.0;
    self.placeholderLabel.frame = CGRectMake(leftMargin + self.contentInset.left, topMargin + self.contentInset.top, self.frame.size.width - - leftMargin * 2 - self.contentInset.left - self.contentInset.right, self.frame.size.height - topMargin - self.contentInset.top - self.contentInset.bottom);
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    [self.placeholderLabel sizeToFit];
    self.placeholderLabel.hidden = [self.text length];
    if (!self.placeholderLabel.superview) {
        [self addSubview:self.placeholderLabel];
    }
    
    CGFloat counterLabelWidth = 50.;
    CGFloat counterLabelHeight = 14.;
    CGFloat counterLabelRight = 6.;
    CGFloat counterLabelBottom = -3;
    /*self.counterLabel.frame = CGRectMake(self.frame.size.width - counterLabelWidth - counterLabelRight - self.contentInset.right, self.contentOffset.y + self.frame.size.height - self.contentInset.bottom - counterLabelHeight - counterLabelBottom, counterLabelWidth, counterLabelHeight);*/
    self.counterLabel.frame = CGRectMake(self.frame.size.width - counterLabelWidth - counterLabelRight - self.contentInset.right,
                                         self.frame.size.height - 17 - counterLabelBottom, counterLabelWidth, counterLabelHeight);
    self.counterLabel.font = self.font;
    self.counterLabel.backgroundColor = [UIColor clearColor];
    self.counterLabel.textColor = [UIColor lightGrayColor];
    [self updateCounterLabelVisibility];
    if (!self.counterLabel.superview) {
        [self addSubview:self.counterLabel];
    }
}

#pragma mark - getters & setters

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self.placeholderLabel sizeToFit];
}

- (void) updateCounterLabelVisibility {
    if (self.text.length > 0 && self.isFirstResponder && [self hasCounter]) {
        self.counterLabel.hidden = NO;
    } else {
        self.counterLabel.hidden = YES;
    }
}

- (void)setCounterText:(NSUInteger)charactersLeft {
    self.counterLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)charactersLeft];
}

- (void)setMaxCharacters:(NSUInteger)maxCharacters {
    _maxCharacters = maxCharacters;
    NSString* textWithoutSpaces = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self setCounterText:maxCharacters - [textWithoutSpaces length]];
    [self updateCounterLabelVisibility];
    //self.counterLabel.hidden = (![self hasCounter] && ![self.text length]);
    //self.contentInset = UIEdgeInsetsMake(0., 0., [self hasCounter] ? 17. : 0., 0.);
}

#pragma mark - text editing events

- (void)textChanged:(NSNotification *)notification {
    NSString* textWithoutSpaces = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([self.placeholder length]) {
        self.placeholderLabel.hidden = [textWithoutSpaces length];
    }
    if (self.maxCharacters > 0) {
        if ((self.markedTextRange == nil) && (self.maxCharacters < [textWithoutSpaces length])) {
            self.text = [self.text substringToIndex:self.text.length - 1];
            textWithoutSpaces = [textWithoutSpaces substringToIndex:self.maxCharacters];
        }
        [self setCounterText:self.maxCharacters - [textWithoutSpaces length]];
    }
}

@end
