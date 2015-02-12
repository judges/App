//
//  WQProductPropertyCell.m
//  App
//
//  Created by 邱成西 on 15/2/6.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQProductPropertyCell.h"



@interface WQProductPropertyCell ()

@property (nonatomic, weak) IBOutlet UIButton *addPropertyBtn;

@property (nonatomic, weak) IBOutlet UIView *lineView;
@end

@implementation WQProductPropertyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"WQProductPropertyCell" owner:self options: nil];
        self = [arrayOfViews objectAtIndex:0];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setIsCouldExtend:(BOOL)isCouldExtend {
    _isCouldExtend = isCouldExtend;
    if (isCouldExtend) {
        self.addPropertyBtn.hidden = NO;
        self.titleTextField.hidden = YES;
        self.infoTextField.hidden = YES;
        self.lineView.hidden = YES;
    }else {
        self.addPropertyBtn.hidden = YES;
        self.titleTextField.hidden = NO;
        self.infoTextField.hidden = NO;
        self.lineView.hidden = NO;
    }
}

-(void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    
    self.titleTextField.idxPath = indexPath;
    self.infoTextField.idxPath = indexPath;
    
    self.titleTextField.userInteractionEnabled = NO;
    
    if (indexPath.section==0) {//固定属性
        if (indexPath.row==0) {
        }else if (indexPath.row==1) {
            self.infoTextField.keyboardType = UIKeyboardTypeNumberPad;
        }else if (indexPath.row==2) {
            self.infoTextField.placeholder = @"最多20个字";
        }
    }
    
}

-(void)setTextString:(NSString *)textString {
    _textString = textString;
    
    if (self.indexPath.section==0) {//固定属性
        NSArray *array = [textString componentsSeparatedByString:@":"];
        
        self.titleTextField.text = [Utility checkString:array[0]]?array[0]:@"";
        
        self.infoTextField.text = [Utility checkString:array[1]]?array[1]:@"";
        
        SafeRelease(array);
    }
    
}


-(IBAction)addPropertyBtnPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addProperty:)]) {
        [self.delegate addProperty:self];
    }
}
@end