//
//  WQCreatProductVC.m
//  App
//
//  Created by 邱成西 on 15/4/8.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQCreatProductVC.h"

#import "WQProAttributeCell.h"
#import "WQProAttributrFooter.h"

#import "WQProAttributeWithImgCell.h"

#import "WQClassObj.h"
#import "WQClassLevelObj.h"
#import "WQColorObj.h"
#import "WQSizeObj.h"

#import "WQClassVC.h"
#import "WQColorVC.h"
#import "WQSizeVC.h"

#import "JKImagePickerController.h"

#import "WQCustomerObj.h"

#import "BlockAlertView.h"

#import "WQCustomerVC.h"

#import "WQProductSaleVC.h"

///一级
static NSIndexPath *selectedProImageIndex = nil;
///二级  尺码
static NSInteger selectedIndex = -1;

@interface WQCreatProductVC ()<UITableViewDataSource, UITableViewDelegate,WQProAttributrFooterDelegate,WQProAttributeWithImgCellDelegate,WQColorVCDelegate,WQClassVCDelegate,WQSizeVCDelegate,JKImagePickerControllerDelegate,RMSwipeTableViewCellDelegate,WQProAttributeCellDelegate,WQCustomerVCDelegate,WQProductSaleVCDelegate>

@property (nonatomic, strong) UITableView *tableView;

///没有图片的数组
@property (nonatomic, strong) NSMutableArray *originArray;
///带图片的数组
@property (nonatomic, strong) NSMutableArray *dataArray;
///创建商品的时候是否包含图片
@property (nonatomic, assign) BOOL isContainProImg;

@property (nonatomic, assign) CGFloat keyboardHeight;

///商品分类
@property (nonatomic, strong) WQClassObj *selectedClassObj;
@property (nonatomic, strong) WQClassLevelObj *selectedLevelClassObj;
///选择的推荐客户
@property (nonatomic, strong) NSMutableArray *selectedCustomers;
///是否热卖
@property (nonatomic, assign) BOOL isHotting;
///是否上架
@property (nonatomic, assign) BOOL isOnSale;
///传给后台数据
@property (nonatomic, strong) NSMutableDictionary *postDictionary;
@end

@implementation WQCreatProductVC
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"containerWillBeginDragging" object:nil];
}

#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setArrayData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //滑动scrollview
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(containerWillBeginDragging:) name:@"containerWillBeginDragging" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"containerWillBeginDragging" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private 

/*
 status:
 
 0=名称
 1=价格和库存----没有图片
 2=有图片
 3=分类
 4=客户
 5=完成创建
 6=热卖
 7=优惠方式
 8=上架
 */
//初始化数据
-(void)setArrayData {
    self.isContainProImg = YES;
    self.postDictionary = nil;
    self.originArray = [[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc]init];
    
    ///商品名称
    NSDictionary *aDic1 = @{@"titleName":NSLocalizedString(@"ProductDetail", @""),@"name":@"",@"status":@"0"};
    [self.originArray addObject:aDic1];
    [self.dataArray addObject:aDic1];
    
    ///商品价格和库存    针对未添加图片
    NSDictionary *aDic2 = @{@"titlePrice":NSLocalizedString(@"ProductPrice", @""),@"price":@"",@"titleStock":NSLocalizedString(@"ProductStock", @""),@"stock":@"",@"status":@"1"};
    [self.originArray addObject:aDic2];
    
    ///商品分类
    NSDictionary *aDic3 = @{@"titleClass":NSLocalizedString(@"SelectedProClass", @""),@"details":@"",@"status":@"3"};
    [self.originArray addObject:aDic3];
    [self.dataArray addObject:aDic3];
    
    ///推荐客户
    NSDictionary *aDic4 = @{@"titleCustomer":NSLocalizedString(@"RecommendProduct", @""),@"details":@"0",@"status":@"4"};
    [self.originArray addObject:aDic4];
    [self.dataArray addObject:aDic4];
    
    ///优惠方式
    NSDictionary *aDic7 = @{@"titleSale":NSLocalizedString(@"ProductSaleType", @""),@"details":@"0",@"status":@"7",@"type":@"-1",@"start":@"",@"end":@"",@"limit":@""};
    [self.originArray addObject:aDic7];
    [self.dataArray addObject:aDic7];
    
    //热卖
    NSDictionary *aDic14 = @{@"titleHot":NSLocalizedString(@"ProductHotSale", @""),@"isOn":@"0",@"status":@"6"};
    [self.originArray addObject:aDic14];
    [self.dataArray addObject:aDic14];
    
    //上架
    self.isOnSale = YES;
    NSDictionary *aDic15 = @{@"titleHot":NSLocalizedString(@"ProductOnSale", @""),@"isOn":@"1",@"status":@"8"};
    [self.originArray addObject:aDic15];
    [self.dataArray addObject:aDic15];
    
    ///完成创建
    NSDictionary *aDic5 = @{@"titleFinish":NSLocalizedString(@"AddProduct", @""),@"status":@"5"};
    [self.originArray addObject:aDic5];
    [self.dataArray addObject:aDic5];
    
    ///尺码、价格、库存
    NSDictionary *aDic23 = @{@"sizeTitle":NSLocalizedString(@"ProductSize", @""),@"sizeDetail":@"",@"priceTitle":NSLocalizedString(@"ProductPrice", @""),@"priceDetail":@"",@"stockTitle":NSLocalizedString(@"ProductStock", @""),@"stockDetail":@""};
    NSArray *array = @[aDic23];
    
    NSDictionary *aDic21 = @{@"image":@"",@"color":@"",@"property":array,@"status":@"2"};
    [self.dataArray insertObject:aDic21 atIndex:self.dataArray.count-6];
    
    
    [self.tableView reloadData];
    
    SafeRelease(aDic1);
    SafeRelease(aDic2);
    SafeRelease(aDic3);
    SafeRelease(aDic4);
    SafeRelease(aDic5);
    SafeRelease(aDic7);
    SafeRelease(aDic15)
}

#pragma mark - property

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[WQProAttributrFooter class] forHeaderFooterViewReuseIdentifier:@"WQProAttributrFooter"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
-(NSMutableDictionary *)postDictionary {
    if (!_postDictionary) {
        _postDictionary = [NSMutableDictionary dictionary];
    }
    return _postDictionary;
}
-(NSMutableArray *)selectedCustomers {
    if (!_selectedCustomers) {
        _selectedCustomers = [NSMutableArray array];
    }
    return _selectedCustomers;
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSArray *array = [self returnArray];
    if (section==0) {
        return 0;
    }else if (section==array.count-6) {
        return 40;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *array = [self returnArray];
    if (section == array.count-6) {
        WQProAttributrFooter *footer = (WQProAttributrFooter *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"WQProAttributrFooter"];
        footer.footDelegate = self;
        return footer;
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *array = [self returnArray];
    return array.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isContainProImg) {
        NSDictionary *aDic = (NSDictionary *)self.dataArray[indexPath.section];
        if ([[aDic objectForKey:@"status"]integerValue]==2) {
            NSArray *array = [aDic objectForKey:@"property"];
            ///尺码、库存、价格 30；  添加更多规格30；  图片60
            return array.count*3*30+30+60;
        }
        return 40;
    }else {
        NSDictionary *aDic = (NSDictionary *)self.originArray[indexPath.section];
        if ([[aDic objectForKey:@"status"]integerValue]==1) {
            return 80;
        }
        return 40;
    }
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isContainProImg) {
        NSDictionary *aDic = (NSDictionary *)self.dataArray[indexPath.section];
        NSInteger status = [[aDic objectForKey:@"status"]integerValue];
        
        if (status==2) {//有图片
            static NSString * identifier = @"CreatProCellImage_";
            
            WQProAttributeWithImgCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell=[[WQProAttributeWithImgCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.revealDirection = RMSwipeTableViewCellRevealDirectionRight;
            [cell setProductVC:self];
            [cell setIndexPath:indexPath];
            cell.attributeWithImgDelegate = self;
            cell.delegate = self;
            
            [cell setDictionary:aDic];
            
            return cell;
        }else {//Default
            static NSString * identifier = @"CreatProCellImageDefault";
            
            WQProAttributeCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell=[[WQProAttributeCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier ];
            }
            if (status==3 || status==4 || status==5|| status==6 || status==7|| status==8) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                if (status==5|| status==6|| status==8) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }else{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            [cell setProductVC:self];
            [cell setIdxPath:indexPath];
            [cell setDataDic:aDic];
            cell.delegate = self;
            return cell;
        }
    }else {
        static NSString * identifier = @"CreatProCellDefault";
        
        WQProAttributeCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[WQProAttributeCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        NSDictionary *aDic = (NSDictionary *)self.originArray[indexPath.section];
        
        NSInteger status = [[aDic objectForKey:@"status"]integerValue];
        
        if (status==3 || status==4 || status==5 || status==6 || status==7|| status==8) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            if (status==5|| status==6|| status==8) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [cell setProductVC:self];
        [cell setIdxPath:indexPath];
        [cell setDataDic:aDic];
        cell.delegate = self;
        return cell;
    }
    
    return nil;
}
-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    if (point.x < 0 && (0-point.x) >= 60) {
        swipeTableViewCell.shouldAnimateCellReset = YES;
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Alert Title" message:NSLocalizedString(@"ConfirmDelete", @"")];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"") block:nil];
        [alert setDestructiveButtonWithTitle:NSLocalizedString(@"Confirm", @"") block:^{
            NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
            
            swipeTableViewCell.shouldAnimateCellReset = NO;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, swipeTableViewCell.contentView.frame.size.width, 0);
                             }
                             completion:^(BOOL finished) {
                                 [self.dataArray removeObjectAtIndex:indexPath.section];
                                 [swipeTableViewCell setHidden:YES];
                                 
                                 if (self.dataArray.count==7) {
                                     self.isContainProImg = NO;
                                 }
                                 [self.tableView reloadData];
                             }
             ];
        }];
        [alert show];
    }
}
-(NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view.subviews makeObjectsPerformSelector:@selector(endEditing:)];
    
    NSArray *array = [self returnArray];
    if (indexPath.section == array.count-1) {//完成创建
        if (self.isContainProImg) {
            BOOL res = [self getPostStringWithImage];
            if (res) {
                [MBProgressHUD showHUDAddedTo:self.appDel.window.rootViewController.view animated:YES];
                [self.postDictionary setObject:@"1" forKey:@"type"];
                
                [self upLoadImageArray:[self.postDictionary objectForKey:@"proImgArray"]];
            }else
                return;
        }else {
            BOOL res = [self getPostStringWithoutImage];
            if (res) {
                [MBProgressHUD showHUDAddedTo:self.appDel.window.rootViewController.view animated:YES];
                [self.postDictionary setObject:@"0" forKey:@"type"];
                
                [self saveProduct];
                
            }else
                return;
        }
    }else if (indexPath.section == array.count-4){//优惠方式
        __block WQProductSaleVC *saleVC = [[WQProductSaleVC alloc]init];
        saleVC.delegate = self;
        saleVC.selectedIndexPath = indexPath;
        if (self.isContainProImg) {
            saleVC.objectDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[self.dataArray.count-4]];
        }else {
            saleVC.objectDic = [[NSMutableDictionary alloc]initWithDictionary:self.originArray[self.originArray.count-4]];
        }
        
        [self.view.window.rootViewController presentViewController:saleVC animated:YES completion:^{
            SafeRelease(saleVC);
        }];
    }else if (indexPath.section == array.count-5){//推荐客户
        __block WQCustomerVC *customerVC = [[WQCustomerVC alloc]init];
        customerVC.isPresentVC = YES;
        customerVC.selectedList = self.selectedCustomers;
        customerVC.delegate = self;
        customerVC.selectedIndexPath = indexPath;
        [self.view.window.rootViewController presentViewController:customerVC animated:YES completion:^{
            SafeRelease(customerVC);
        }];
    }else if (indexPath.section == array.count-6){//选择分类
        __block WQClassVC *classVC = [[WQClassVC alloc]init];
        classVC.delegate = self;
        classVC.isPresentVC = YES;
        classVC.selectedIndexPath = indexPath;
        classVC.selectedClassBObj = self.selectedLevelClassObj;
        [self.view.window.rootViewController presentViewController:classVC animated:YES completion:^{
            SafeRelease(classVC);
        }];
    }
}

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 30;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

-(NSArray *)returnArray {
    if (self.isContainProImg) {
        return self.dataArray;
    }
    return self.originArray;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view.subviews makeObjectsPerformSelector:@selector(endEditing:)];
}
#pragma mark -
#pragma mark - 整合数据传给后台

-(BOOL)predicateText:(NSString *)text regex:(NSString *)regex {
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![test evaluateWithObject:text]){
        return NO;
    }else {
        return YES;
    }
}

///未选图片
-(BOOL)getPostStringWithoutImage {
    BOOL isPost = NO;
    for (int i=0; i<self.originArray.count; i++) {
        NSDictionary *aDic = (NSDictionary *)self.originArray[i];
        
        NSInteger status = [[aDic objectForKey:@"status"]integerValue];
        if (status==0) {///商品名称
            if ([Utility checkString:[aDic objectForKey:@"name"]]) {
                isPost = YES;
                [self.postDictionary setObject:[aDic objectForKey:@"name"] forKey:@"productName"];
            }else {
                isPost = NO;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"NameError", @"")];
                self.postDictionary = nil;
                break;
            }
        }else if (status==1) {///商品价格和库存
            NSString *priceString = [aDic objectForKey:@"price"];
            if (priceString.length==0) {
                isPost = NO;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"PriceError", @"")];
                self.postDictionary = nil;
                break;
            }else {
                if ([self predicateText:priceString regex:@"^[0-9]+(.[0-9]{1,2})?$"]) {
                    isPost = YES;
                    [self.postDictionary setObject:priceString forKey:@"productPrice"];
                }else {
                    isPost = NO;
                    [WQPopView showWithImageName:@"PriceConfirmError" message:NSLocalizedString(@"PriceError", @"")];
                    self.postDictionary = nil;
                    break;
                }
            }
            
            NSString *stockString = [aDic objectForKey:@"stock"];
            if (stockString.length==0) {
                isPost = NO;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"StockError", @"")];
                self.postDictionary = nil;
                break;
            }else {
                if ([self predicateText:stockString regex:@"^[0-9]*$"]) {
                    isPost = YES;
                    [self.postDictionary setObject:stockString forKey:@"productStock"];
                }else {
                    isPost = NO;
                    [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"StockConfirmError", @"")];
                    self.postDictionary = nil;
                    break;
                }
            }
        }
    }
    
    if (self.selectedLevelClassObj && self.selectedClassObj && isPost) {
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.selectedLevelClassObj.levelClassId] forKey:@"proClassBId"];
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.selectedClassObj.classId] forKey:@"proClassAId"];
    }else {
        isPost = NO;
        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"ClassSelectedError", @"")];
        self.postDictionary = nil;
    }
    
    if (isPost) {
        [self.postDictionary setObject:self.selectedCustomers forKey:@"customer"];
        
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.isHotting] forKey:@"productIsHot"];
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.isOnSale] forKey:@"productIsSale"];
        
        NSDictionary *dic = (NSDictionary *)self.originArray[self.originArray.count-4];
        [self.postDictionary setObject:[NSNumber numberWithInteger:([[dic objectForKey:@"type"] integerValue]+1)] forKey:@"proOnSaleType"];
        [self.postDictionary setObject:[dic objectForKey:@"details"] forKey:@"onSalePrice"];
        [self.postDictionary setObject:[dic objectForKey:@"start"] forKey:@"proSaleStartTime"];
        [self.postDictionary setObject:[dic objectForKey:@"end"] forKey:@"proSaleEndTime"];
        [self.postDictionary setObject:[dic objectForKey:@"limit"] forKey:@"onSaleStock"];
    }
    
    
    return isPost;
}

///选择图片
-(BOOL)getPostStringWithImage {
    BOOL isPost = NO;
    
    for (int i=0; i<self.dataArray.count; i++) {
        NSDictionary *aDic = (NSDictionary *)self.dataArray[i];
        
        NSInteger status = [[aDic objectForKey:@"status"]integerValue];
        if (status==0) {///商品名称
            if ([Utility checkString:[aDic objectForKey:@"name"]]) {
                isPost = YES;
                [self.postDictionary setObject:[aDic objectForKey:@"name"] forKey:@"productName"];
            }else {
                isPost = NO;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"NameError", @"")];
                self.postDictionary = nil;
                break;
            }
        }else if (status==2) {///商品
           
            NSMutableArray *imageArray = nil;
            if (![[self.postDictionary objectForKey:@"proImgArray"] isKindOfClass:[NSNull class]] && [self.postDictionary objectForKey:@"proImgArray"]!= nil) {
                imageArray = [NSMutableArray arrayWithArray:[self.postDictionary objectForKey:@"proImgArray"]];
            }else {
                imageArray = [[NSMutableArray alloc]init];
            }
            
             NSMutableDictionary *imageDic = [[NSMutableDictionary alloc]init];
            ///商品图片
            if ([[aDic objectForKey:@"image"]isKindOfClass:[UIImage class]] && [aDic objectForKey:@"image"]!=nil) {
                UIImage *image = (UIImage *)[aDic objectForKey:@"image"];
                [imageDic setObject:image forKey:@"productImg"];
                isPost = YES;
            }else {
                isPost = NO;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"ImageError", @"")];
                self.postDictionary = nil;
                break;
            }
            ///商品颜色
            if ([[aDic objectForKey:@"color"] isKindOfClass:[WQColorObj class]] && [aDic objectForKey:@"color"]!=nil) {
                WQColorObj *color = (WQColorObj *)[aDic objectForKey:@"color"];
                [imageDic setObject:[NSNumber numberWithInteger:color.colorId] forKey:@"productColor"];
                isPost = YES;
            }else {
                isPost = NO;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"ColorError", @"")];
                self.postDictionary = nil;
                break;
            }
            
            BOOL isContinue = NO;
            
            NSMutableArray *sizeArray = [[NSMutableArray alloc]init];
            NSArray *array = [aDic objectForKey:@"property"];
            for (int i=0; i<array.count; i++) {
                NSDictionary *dic = (NSDictionary *)array[i];
                NSMutableDictionary *sizeDic = [[NSMutableDictionary alloc]init];
                ///尺码
                if ([[dic objectForKey:@"sizeDetail"]isKindOfClass:[WQSizeObj class]] && [dic objectForKey:@"sizeDetail"]!=nil) {
                    WQSizeObj *size = (WQSizeObj *)[dic objectForKey:@"sizeDetail"];
                    [sizeDic setObject:[NSNumber numberWithInteger:size.sizeId] forKey:@"productSize"];
                    isContinue = YES;
                }else {
                    isContinue = NO;
                    [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"SizeError", @"")];
                    break;
                }
                ///价格
                NSString *priceString = [dic objectForKey:@"priceDetail"];
                if (priceString.length==0) {
                    isContinue = NO;
                    [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"PriceError", @"")];
                    break;
                }else {
                    if ([self predicateText:priceString regex:@"^[0-9]+(.[0-9]{1,2})?$"]) {
                        isContinue = YES;
                        [sizeDic setObject:priceString forKey:@"productPrice"];
                    }else {
                        isContinue = NO;
                        [WQPopView showWithImageName:@"PriceConfirmError" message:NSLocalizedString(@"PriceError", @"")];
                        break;
                    }
                }
                ///库存
                NSString *stockString = [dic objectForKey:@"stockDetail"];
                if (stockString.length==0) {
                    isContinue = NO;
                    [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"StockError", @"")];
                    break;
                }else {
                    if ([self predicateText:stockString regex:@"^[0-9]*$"]) {
                        isContinue = YES;
                        [sizeDic setObject:stockString forKey:@"productStock"];
                    }else {
                        isContinue = NO;
                        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"StockConfirmError", @"")];
                        break;
                    }
                }
                
                [sizeArray addObject:sizeDic];
                SafeRelease(sizeDic);
            }
            [imageDic setObject:sizeArray forKey:@"proSizeArray"];
            SafeRelease(sizeArray);
            
            [imageArray addObject:imageDic];
            SafeRelease(imageDic);
            
            [self.postDictionary setObject:imageArray forKey:@"proImgArray"];
            SafeRelease(imageArray);
            
            if (!isContinue) {
                self.postDictionary = nil;
                isPost = NO;
                break;
            }
        }
    }
    
    if (self.selectedLevelClassObj && self.selectedClassObj && isPost) {
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.selectedLevelClassObj.levelClassId] forKey:@"proClassBId"];
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.selectedClassObj.classId] forKey:@"proClassAId"];
    }else {
        isPost = NO;
        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"ClassSelectedError", @"")];
        self.postDictionary = nil;
    }
    
    if (isPost) {
        [self.postDictionary setObject:self.selectedCustomers forKey:@"customer"];
        
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.isHotting] forKey:@"productIsHot"];
        [self.postDictionary setObject:[NSNumber numberWithInteger:self.isOnSale] forKey:@"productIsSale"];
        
        NSDictionary *dic = (NSDictionary *)self.dataArray[self.dataArray.count-4];
        [self.postDictionary setObject:[NSNumber numberWithInteger:([[dic objectForKey:@"type"] integerValue]+1)] forKey:@"proOnSaleType"];
        [self.postDictionary setObject:[dic objectForKey:@"details"] forKey:@"onSalePrice"];
        [self.postDictionary setObject:[dic objectForKey:@"start"] forKey:@"proSaleStartTime"];
        [self.postDictionary setObject:[dic objectForKey:@"end"] forKey:@"proSaleEndTime"];
        [self.postDictionary setObject:[dic objectForKey:@"limit"] forKey:@"onSaleStock"];
    }
    
    return isPost;
}

#pragma mark - 添加商品型号
-(void)addMoreProType {
    [self.view.subviews makeObjectsPerformSelector:@selector(endEditing:)];
    
    self.isContainProImg = YES;
    
    ///尺码、价格、库存
    NSDictionary *aDic = @{@"sizeTitle":NSLocalizedString(@"ProductSize", @""),@"sizeDetail":@"",@"priceTitle":NSLocalizedString(@"ProductPrice", @""),@"priceDetail":@"",@"stockTitle":NSLocalizedString(@"ProductStock", @""),@"stockDetail":@""};
    NSArray *array = @[aDic];
    
    NSDictionary *aDic2 = @{@"image":@"",@"color":@"",@"property":array,@"status":@"2"};
    
    [self.dataArray insertObject:aDic2 atIndex:self.dataArray.count-6];
    
    [self.tableView reloadData];
}

#pragma mark - WQProAttributeWithImgCellDelegate 有图片
#pragma mark - 选择颜色
-(void)selectedProductColor:(WQProductBtn *)colorBtn {
    selectedProImageIndex = colorBtn.idxPath;
    
    __block WQColorVC *colorVC = [[WQColorVC alloc]init];
    colorVC.isPresentVC = YES;
    colorVC.delegate = self;
    colorVC.selectedIndexPath = colorBtn.idxPath;
    
    ///选择的颜色
    NSDictionary *object = (NSDictionary *)self.dataArray[selectedProImageIndex.section];
    if ([[object objectForKey:@"color"] isKindOfClass:[WQColorObj class]] && [object objectForKey:@"color"]!=nil) {
        colorVC.selectedColorObj = (WQColorObj *)[object objectForKey:@"color"];
    }else {
        colorVC.selectedColorObj = nil;
    }
    
    [self.view.window.rootViewController presentViewController:colorVC animated:YES completion:^{
        SafeRelease(colorVC);
    }];
}

//选择颜色代理回调
-(void)colorVC:(WQColorVC *)colorVC selectedColor:(WQColorObj *)colorObj {
    __weak typeof(self) weakSelf = self;
    [colorVC dismissViewControllerAnimated:YES completion:^{
        
        WQProAttributeWithImgCell *cell = (WQProAttributeWithImgCell *)[weakSelf.tableView cellForRowAtIndexPath:selectedProImageIndex];
        cell.colorObj = colorObj;
        
        ///更改数据
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[selectedProImageIndex.section]];
        [mutableDic setObject:colorObj forKey:@"color"];
        [self.dataArray replaceObjectAtIndex:selectedProImageIndex.section withObject:mutableDic];
        selectedProImageIndex = nil;
    }];
}
#pragma mark - 添加图片

-(void)selectedProductImage:(WQProAttributeWithImgCell *)cell {
    DLog(@"添加图片");
    selectedProImageIndex = cell.indexPath;
    __block JKImagePickerController *imagePicker = [[JKImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsMultipleSelection = NO;
    imagePicker.minimumNumberOfSelection = 1;
    imagePicker.maximumNumberOfSelection = 1;
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:^{
        SafeRelease(imagePicker);
    }];
}

/// JKImagePickerControllerDelegate

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets{
    [MBProgressHUD showHUDAddedTo:self.appDel.window.rootViewController.view animated:YES];
    
    __weak typeof(self) weakSelf = self;
    JKAssets *asset = (JKAssets *)assets[0];
    __block UIImage *image = nil;
    ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            UIImage *tempImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            image = [Utility dealImageData:tempImg];//图片处理
            SafeRelease(tempImg);
        }
    } failureBlock:^(NSError *error) {
        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"PhotoSelectedError", @"")];
        [MBProgressHUD hideAllHUDsForView:self.appDel.window.rootViewController.view animated:YES];
    }];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        WQProAttributeWithImgCell *cell = (WQProAttributeWithImgCell *)[weakSelf.tableView cellForRowAtIndexPath:selectedProImageIndex];
        cell.proImgView.image = image;
        
        ///更改数据
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[selectedProImageIndex.section]];
        [mutableDic setObject:image forKey:@"image"];
        [self.dataArray replaceObjectAtIndex:selectedProImageIndex.section withObject:mutableDic];
        selectedProImageIndex = nil;
        [MBProgressHUD hideAllHUDsForView:weakSelf.appDel.window.rootViewController.view animated:YES];
    }];
}
- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker {
    selectedProImageIndex = nil;
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - 选择尺码
-(void)selectedProductSize:(WQProductBtn *)sizeBtn {
    DLog(@"选择尺码");
    selectedProImageIndex = sizeBtn.idxPath;
    selectedIndex = sizeBtn.tag - SizeTextFieldTag;

    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSDictionary *object = (NSDictionary *)self.dataArray[selectedProImageIndex.section];
    NSArray *array = (NSArray *)[object objectForKey:@"property"];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != selectedIndex) {
            NSDictionary *dic = (NSDictionary *)obj;
            if ([[dic objectForKey:@"sizeDetail"]isKindOfClass:[WQSizeObj class]] && [dic objectForKey:@"sizeDetail"]!=nil) {
                WQSizeObj *size = (WQSizeObj *)[dic objectForKey:@"sizeDetail"];
                [tempArray addObject:[NSString stringWithFormat:@"%d",size.sizeId]];
            }
        }
    }];

    __block WQSizeVC *sizeVC = [[WQSizeVC alloc]init];
    sizeVC.isPresentVC = YES;
    sizeVC.delegate = self;
    sizeVC.selectedIndexPath = sizeBtn.idxPath;
    sizeVC.hasSelectedSize = tempArray;
    
    NSDictionary *aDic = (NSDictionary *)array[selectedIndex];
    if ([[aDic objectForKey:@"sizeDetail"]isKindOfClass:[WQSizeObj class]] && [aDic objectForKey:@"sizeDetail"]!=nil) {
        sizeVC.selectedSizeObj = (WQSizeObj *)[object objectForKey:@"sizeDetail"];
    }else {
        sizeVC.selectedSizeObj = nil;
    }
    [self.view.window.rootViewController presentViewController:sizeVC animated:YES completion:^{
        SafeRelease(sizeVC);
    }];
}

///选择尺码代理回调
-(void)sizeVC:(WQSizeVC *)sizeVC selectedSize:(WQSizeObj *)sizeObj{
    __weak typeof(self) weakSelf = self;
    [sizeVC dismissViewControllerAnimated:YES completion:^{
        WQProAttributeWithImgCell *cell = (WQProAttributeWithImgCell *)[weakSelf.tableView cellForRowAtIndexPath:selectedProImageIndex];
        WQProductBtn *sizeBtn = (WQProductBtn *)[cell.contentView viewWithTag:(SizeTextFieldTag+selectedIndex)];
        [sizeBtn setTitle:sizeObj.sizeName forState:UIControlStateNormal];
        
        ///更改数据
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[selectedProImageIndex.section]];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[mutableDic objectForKey:@"property"]];
        NSMutableDictionary *aDic = [[NSMutableDictionary alloc]initWithDictionary:array[selectedIndex]];
        [aDic setObject:sizeObj forKey:@"sizeDetail"];
        [array replaceObjectAtIndex:selectedIndex withObject:aDic];
        [mutableDic setObject:array forKey:@"property"];
        [self.dataArray replaceObjectAtIndex:selectedProImageIndex.section withObject:mutableDic];
        selectedProImageIndex = nil;
        selectedIndex = -1;
    }];
}

#pragma mark - 删除尺码、价格、库存
-(void)deleteProductSize:(WQProductBtn *)deleteBtn {
    DLog(@"删除尺码、价格、库存");
    
    ///更改数据
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[deleteBtn.idxPath.section]];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[mutableDic objectForKey:@"property"]];

    [mutableArray removeObjectAtIndex:(deleteBtn.tag-DeleteBtnTag)];
    
    if (mutableArray.count==0) {
        [self.dataArray removeObjectAtIndex:deleteBtn.idxPath.section];
        
        if (self.dataArray.count==7) {
            self.isContainProImg = NO;
        }
        [self.tableView reloadData];
    }else {
        [mutableDic setObject:mutableArray forKey:@"property"];
        [self.dataArray replaceObjectAtIndex:deleteBtn.idxPath.section withObject:mutableDic];
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:deleteBtn.idxPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}
#pragma mark - 添加尺码、价格、库存
-(void)addProductSize:(WQProductBtn *)addBtn {
    ///更改数据
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[addBtn.idxPath.section]];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[mutableDic objectForKey:@"property"]];
    NSDictionary *aDic = @{@"sizeTitle":NSLocalizedString(@"ProductSize", @""),@"sizeDetail":@"",@"priceTitle":NSLocalizedString(@"ProductPrice", @""),@"priceDetail":@"",@"stockTitle":NSLocalizedString(@"ProductStock", @""),@"stockDetail":@""};
    [mutableArray addObject:aDic];
    [mutableDic setObject:mutableArray forKey:@"property"];
    [self.dataArray replaceObjectAtIndex:addBtn.idxPath.section withObject:mutableDic];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:addBtn.idxPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - 选择分类
-(void)classVC:(WQClassVC *)classVC classA:(WQClassObj *)classObj classB:(WQClassLevelObj *)levelClassObj {
    [classVC dismissViewControllerAnimated:YES completion:^{
        self.selectedClassObj = classObj;
        self.selectedLevelClassObj = levelClassObj;
        
        NSMutableDictionary *mutableDic = nil;
        if (self.isContainProImg) {
            mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[self.dataArray.count-6]];
        }else {
            mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.originArray[self.originArray.count-6]];
        }
        [mutableDic setObject:levelClassObj.levelClassName forKey:@"details"];
        [self.originArray replaceObjectAtIndex:(self.originArray.count-6) withObject:mutableDic];
        [self.dataArray replaceObjectAtIndex:(self.dataArray.count-6) withObject:mutableDic];
        
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[classVC.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}
#pragma mark - 选择客户
- (void)customerVC:(WQCustomerVC *)customerVC didSelectCustomers:(NSArray *)customers {
    [customerVC dismissViewControllerAnimated:YES completion:^{
        self.selectedCustomers = [NSMutableArray arrayWithArray:customers];
        
        NSMutableDictionary *mutableDic = nil;
        if (self.isContainProImg) {
            mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[self.dataArray.count-5]];
        }else {
            mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.originArray[self.originArray.count-5]];
        }
        [mutableDic setObject:[NSNumber numberWithInt:customers.count] forKey:@"details"];
        [self.originArray replaceObjectAtIndex:(self.originArray.count-5) withObject:mutableDic];
        [self.dataArray replaceObjectAtIndex:(self.dataArray.count-5) withObject:mutableDic];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[customerVC.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
    }];
}
#pragma mark - 选择优惠方式
-(void)selectedSale:(WQProductSaleVC *)saleVC object:(NSDictionary *)dictionary {
    [saleVC dismissViewControllerAnimated:YES completion:^{
        [self.originArray replaceObjectAtIndex:(self.originArray.count-4) withObject:dictionary];
        [self.dataArray replaceObjectAtIndex:(self.dataArray.count-4) withObject:dictionary];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[saleVC.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}
#pragma mark - 热卖

-(void)proAttributeCell:(WQProAttributeCell *)cell changeSwitch:(BOOL)isHot {
    if (self.isContainProImg) {
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[cell.idxPath.section]];
        
        [mutableDic setObject:[NSNumber numberWithBool:isHot] forKey:@"isOn"];
        [self.dataArray replaceObjectAtIndex:cell.idxPath.section withObject:mutableDic];
    }else {
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.originArray[cell.idxPath.section]];
        
        [mutableDic setObject:[NSNumber numberWithBool:isHot] forKey:@"isOn"];
        [self.originArray replaceObjectAtIndex:cell.idxPath.section withObject:mutableDic];
    }
    
    if (cell.switchBtn.tag==100) {
        self.isHotting = isHot;
    }else {
        self.isOnSale = isHot;
    }
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame2 = self.tableView.frame;
                         frame2.size.height += self.keyboardHeight;
                         frame2.size.height -= keyboardRect.size.height;
                         self.tableView.frame = frame2;
                         
                         self.keyboardHeight = keyboardRect.size.height;
                     }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         frame.origin.x = 0;
                         self.tableView.frame = frame;
                         
                         self.keyboardHeight = 0;
                         
                     }];
}

- (void)scrollToIndex:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[WQProductText class]]) {
        WQProductText *text = (WQProductText *)textField;
        
        [self scrollToIndex:text.idxPath animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[WQProductText class]]) {
        WQProductText *text = (WQProductText *)textField;
        
        if (self.isContainProImg) {
            ///更改数据
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.dataArray[text.idxPath.section]];
            NSInteger status = [[mutableDic objectForKey:@"status"]integerValue];
            if (status==0) {
                [mutableDic setObject:text.text forKey:@"name"];
                [self.dataArray replaceObjectAtIndex:text.idxPath.section withObject:mutableDic];
                [self.originArray replaceObjectAtIndex:text.idxPath.section withObject:mutableDic];
            }else {
                NSMutableArray *array = [NSMutableArray arrayWithArray:[mutableDic objectForKey:@"property"]];
                
                NSInteger index = 0;
                if (text.tag>=PriceTextFieldTag && text.tag<StockTextFieldTag) {//价格
                    index = text.tag-PriceTextFieldTag;
                    
                    NSMutableDictionary *aDic = [[NSMutableDictionary alloc]initWithDictionary:array[index]];
                    [aDic setObject:text.text forKey:@"priceDetail"];
                    [array replaceObjectAtIndex:index withObject:aDic];
                    
                }else if (text.tag>=StockTextFieldTag){//库存
                    index = text.tag-StockTextFieldTag;
                    
                    NSMutableDictionary *aDic = [[NSMutableDictionary alloc]initWithDictionary:array[index]];
                    [aDic setObject:text.text forKey:@"stockDetail"];
                    [array replaceObjectAtIndex:index withObject:aDic];
                }
                [mutableDic setObject:array forKey:@"property"];
                [self.dataArray replaceObjectAtIndex:text.idxPath.section withObject:mutableDic];
            }
            
        }else {
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:self.originArray[text.idxPath.section]];
            NSInteger status = [[mutableDic objectForKey:@"status"]integerValue];
            if (status==0) {
                [mutableDic setObject:text.text forKey:@"name"];
                [self.dataArray replaceObjectAtIndex:text.idxPath.section withObject:mutableDic];
            }else if (status==1){
                if (text.tag==100) {//textField
                    [mutableDic setObject:text.text forKey:@"price"];
                }else if (text.tag==1000) {//textField2
                    [mutableDic setObject:text.text forKey:@"stock"];
                }
            }
            [self.originArray replaceObjectAtIndex:text.idxPath.section withObject:mutableDic];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isKindOfClass:[WQProductText class]]) {
        WQProductText *text = (WQProductText *)textField;
        
        if (text.returnKeyType == UIReturnKeyDone) {
            [text resignFirstResponder];
        }else if (text.returnKeyType == UIReturnKeyNext){
            WQProAttributeCell *cell = (WQProAttributeCell *)[self.tableView cellForRowAtIndexPath:text.idxPath];
            if (self.isContainProImg) {
                
                WQProductText *textNext = (WQProductText *)[cell.contentView viewWithTag:(text.tag-PriceTextFieldTag+StockTextFieldTag)];
                [textNext becomeFirstResponder];
            }else {
                [cell.textField2 becomeFirstResponder];
            }
        }
    }
    return YES;
}

#pragma mark -

-(void)containerWillBeginDragging:(NSNotification *)notification {
    [self.view.subviews makeObjectsPerformSelector:@selector(endEditing:)];
}


#pragma mark - 上传图像
static NSInteger upLoadImgCount = 0;
-(void)upLoadImageArray:(NSArray *)imgArray {
    if (upLoadImgCount == imgArray.count) {
        [self saveProduct];
    }else {
        NSDictionary *dictionary = (NSDictionary *)imgArray[upLoadImgCount];
        
        if ([[dictionary objectForKey:@"productImg"]isKindOfClass:[UIImage class]] && [dictionary objectForKey:@"productImg"]!=nil) {
            UIImage *image = (UIImage *)[dictionary objectForKey:@"productImg"];
            
            [self postProductImg:image index:upLoadImgCount];
        }else {
            upLoadImgCount ++;
            return  [self upLoadImageArray:[self.postDictionary objectForKey:@"proImgArray"]];
        }
    }
}
-(void)postProductImg:(UIImage *)image index:(NSInteger)index {
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"https://barryhippo.xicp.net:8443/rest/img/uploadProImg" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1)  name:@"imgFile" fileName:@"imgFile.jpeg" mimeType:@"image/jpeg"];
    } error:nil];
    
    [request setValue:@"test" forHTTPHeaderField:@"registractionid"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSProgress *progress = nil;
    
    self.uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonData=(NSDictionary *)responseObject;
                
                if ([[jsonData objectForKey:@"status"]integerValue]==1) {

                    NSDictionary *obj = [jsonData objectForKey:@"returnObj"];
                    NSString *imagePath = [obj objectForKey:@"img"];
                    
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self.postDictionary objectForKey:@"proImgArray"]];
                    NSMutableDictionary *mutableDic = mutableArray[index];
                    [mutableDic setObject:imagePath forKey:@"productImg"];
                    [mutableArray replaceObjectAtIndex:index withObject:mutableDic];
                    [self.postDictionary setObject:mutableArray forKey:@"proImgArray"];
                    
                    
                    upLoadImgCount ++;
                    
                    return  [self upLoadImageArray:[self.postDictionary objectForKey:@"proImgArray"]];
                }else {
                    upLoadImgCount = 0;
                    [WQPopView showWithImageName:@"picker_alert_sigh" message:[jsonData objectForKey:@"msg"]];
                }
            }
        }else {
            upLoadImgCount = 0;
            [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"InterfaceError", @"")];
        }
    }];
    [self.uploadTask resume];
}
//最终创建商品
-(void)saveProduct {
    [self.postDictionary setObject:[NSNumber numberWithInteger:[WQDataShare sharedService].userObj.moneyType] forKey:@"moneyType"];
    
    NSString *jsonString = [self dictionaryToJson:self.postDictionary];
    self.interfaceTask = [WQAPIClient creatProductWithParameters:@{@"product":jsonString} block:^(NSInteger status, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.appDel.window.rootViewController.view animated:YES];
        if (!error && status==1) {
            self.postDictionary = nil;
            [self setArrayData];
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else {
            upLoadImgCount = 0;
        }
    }];
}
@end
