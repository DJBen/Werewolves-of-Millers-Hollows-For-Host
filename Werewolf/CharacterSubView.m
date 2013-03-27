//
//  CharacterSubView.m
//  Werewolf
//
//  Created by Sihao Lu on 3/19/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "CharacterSubView.h"

@implementation CharacterSubView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.portraitImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.portraitImageView.image = [UIImage imageNamed:@"page.png"];
        self.portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.portraitImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.6)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [self.nameLabel.font fontWithSize:self.frame.size.width * 3.2 / 24.0];
        [self addSubview:self.nameLabel];

        self.characterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5, self.frame.size.width, self.frame.size.height * 0.4)];
        self.characterLabel.backgroundColor = [UIColor clearColor];
        self.characterLabel.textAlignment = NSTextAlignmentCenter;
        self.characterLabel.font = [self.characterLabel.font fontWithSize:self.frame.size.width * 2.4 / 24.0];
        [self addSubview:self.characterLabel];
        self.characterLabel.alpha = 0.0;
    }
    return self;
}

- (void) showCharacterLabel:(NSString *)characterName animated:(BOOL)animated {
    self.characterLabel.text = characterName;
    if (!animated) {
        self.characterLabel.alpha = 1.0;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.characterLabel.alpha = 1.0;
        }];
    }
}

- (void) hideCharacterLabelAnimated:(BOOL)animated {
    if (!animated) {
        self.characterLabel.alpha = 0.0;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.characterLabel.alpha = 0.0;
        }];
    }
}

- (void) setSelected:(BOOL)selected {
    _selected = selected;
    if (selected) {
        circle = [[UIImageView alloc] initWithFrame:self.bounds];
        circle.image = [UIImage imageNamed:@"Circle"];
        [self addSubview:circle];
    } else {
        [circle removeFromSuperview];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
