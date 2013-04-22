//
//  DTViewController.h
//  DoubleTouchesToScroll
//
//  Created by Zhou.Bin on 13-4-22.
//  Copyright (c) 2013年 Zhou.Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
