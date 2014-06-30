//
//  GBProfileTableViewCell.h
//  Profiles
//
//  Created by Graham Barker on 30/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GBProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end
