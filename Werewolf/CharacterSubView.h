//
//  CharacterSubView.h
//  Werewolf
//
//  Created by Sihao Lu on 3/19/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharacterSubView : UIView {
    UIImageView *circle;
}

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *characterLabel;
@property (nonatomic, getter = isSelected) BOOL selected;

- (void) showCharacterLabel:(NSString *)characterName animated:(BOOL)animated;
- (void) hideCharacterLabelAnimated:(BOOL)animated;

@end
