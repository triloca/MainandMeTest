//
//  LeftMenuVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LeftMenuVC.h"

@interface LeftMenuVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;

@end

@implementation LeftMenuVC


#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark _______________________ Privat Methods(view)___________________
#pragma mark _______________________ Privat Methods ________________________

- (void)loadData{
    _tableArray = @[@"1", @"2", @"3", @"4"];
}
#pragma mark _______________________ Buttons Action ________________________
#pragma mark _______________________ Delegates _____________________________

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    static NSString *CellIdentifier = @"ClassCell";
    
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    if (cell == nil)
    //    {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //    }
    
    //    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    if (cell == nil){
    //        cell = [ClassCell loadViewFromXIB];
    //        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
    //    }
    
    // Configure the cell...
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark _______________________ Public Methods ________________________
#pragma mark _______________________ Notifications _________________________

@end
