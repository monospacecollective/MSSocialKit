//
//  UILabel+ApplyTextAttributes.m
//  Pods
//
//  Created by Devon Tivona on 3/13/13.
//
//

#import "UILabel+ApplyTextAttributes.h"

@implementation UILabel (ApplyTextAttributes)

- (void)applyTextAttributes:(NSDictionary *)attributes
{
    self.font = (attributes[UITextAttributeFont] ? attributes[UITextAttributeFont] : self.font);
	self.textColor = (attributes[UITextAttributeTextColor] ? attributes[UITextAttributeTextColor] : self.textColor);
	self.shadowColor = (attributes[UITextAttributeTextShadowColor] ? attributes[UITextAttributeTextShadowColor] : self.shadowColor);
	self.shadowOffset = (attributes[UITextAttributeTextShadowOffset] ? [attributes[UITextAttributeTextShadowOffset] CGSizeValue] : self.shadowOffset);
}

@end
