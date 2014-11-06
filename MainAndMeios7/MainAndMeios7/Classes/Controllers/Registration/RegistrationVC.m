//
//  RegistrationVC.m
//  MainAndMeios7
//
//  Created by Bhumi Shah on 03/11/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "RegistrationVC.h"
//#import "SVProgressHUD.h" //! Please use [self showSpinnerWithName:@""];[self hideSpinnerWithName:@""];[self showSpinnerWithName:@""];[self hideSpinnerWithName:@""];
#import "RegistrationCell.h"
@interface RegistrationVC ()

@end

@implementation RegistrationVC

#pragma mark _______________________ View Methods ________________________


- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrPlaceholers = [[NSArray alloc] initWithObjects:@"Full Name",@"Email",@"Password",@"Confirm Password", nil];
    arrKey = [[NSArray alloc] initWithObjects:@"name",@"email",@"password",@"confirmPassword", nil];
    
    dictResult = [[NSMutableDictionary alloc] init];
    self.title=@"Registration";
    
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [dictResult removeAllObjects];
    [tblView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark _______________________ Class Methods _________________________


+ (void)registrationVCPresentation:(void (^)(RegistrationVC* registrationVC))presentation
                           success:(void (^)(RegistrationVC* registrationVC, NSString* token))success
                           failure:(void (^)(RegistrationVC* registrationVC, NSError* error))failure;
 {
    
    RegistrationVC* registrationVC = [RegistrationVC loadFromXIB_Or_iPhone5_XIB];
    registrationVC.successBlock = success;
    registrationVC.failureBlock = failure;

    presentation(registrationVC);
  
}


#pragma mark _______________________ Table View Delegate Methods ________________________

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [arrPlaceholers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    RegistrationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RegistrationCell" owner:self options:nil];
        cell = (RegistrationCell *)[topLevelObjects objectAtIndex:0];
    }
    //
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.txtTitle.tag = indexPath.row;
    cell.txtTitle.delegate = self;
    
    cell.txtTitle.placeholder = [arrPlaceholers objectAtIndex:indexPath.row];
    if([dictResult valueForKey:[NSString stringWithFormat:@"%@",[arrKey objectAtIndex:indexPath.row]]])
    {
        cell.txtTitle.text = [dictResult valueForKey:[NSString stringWithFormat:@"%@",[arrKey objectAtIndex:indexPath.row]]];
    }
    if(indexPath.row == 2 || indexPath.row == 3)
    {
        cell.txtTitle.secureTextEntry = YES;
    }
    
    if (indexPath.row == 1) {
        [cell.txtTitle setKeyboardType:UIKeyboardTypeEmailAddress];
        
    }
    else{
        [cell.txtTitle setKeyboardType:UIKeyboardTypeDefault];
    }
    
    // cell.txtTitle.font = [UIFont fontWithName:FONT_KOZGO_EL size:14];
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


#pragma mark _______________________ Text Field Delegate Methods ________________________

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    txtField=textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [dictResult setObject:txtField.text forKey:[arrKey objectAtIndex:txtField.tag]];
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 50) ? NO : YES;
    
    return YES;
}

#pragma mark _______________________ Button Click Methods ________________________

-(IBAction)btnRegister_Click:(id)sender
{
    if(txtField)
        [txtField resignFirstResponder];
    NSString *strPassword = [dictResult valueForKey:[arrKey objectAtIndex:2]] ;
    
    if(![self validateEmail:[dictResult valueForKey:[arrKey objectAtIndex:1]]])
    {
        //[SVProgressHUD showErrorWithStatus:@"Invalid Email Address"];
        return;
    }
    
    if(![[dictResult valueForKey:[arrKey objectAtIndex:2]] isEqualToString:[dictResult valueForKey:[arrKey objectAtIndex:3]]])
    {
        //[SVProgressHUD showErrorWithStatus: @"Password and Confirm Password do not match"];
        return;
    }
    else if(strPassword.length<8)
    {
        //[SVProgressHUD showErrorWithStatus:@"Password Atleast has 8 Characters"];
        return;
        
    }
    else if([[dictResult valueForKey:[arrKey objectAtIndex:0]] length]==0)
    {
        //[SVProgressHUD showErrorWithStatus:@"Full Name should not be blank"];
        return;
        
    }
    if (_successBlock) {
        _successBlock(self, nil);
    }
    //Register
}

-(IBAction)btnCancel_Click:(id)sender
{
    if (_failureBlock) {
        _failureBlock(self, nil);
    }
}
#pragma mark _______________________ Email Address Validation ________________________



-(BOOL)validateEmail:(NSString *)strEmail
{
    //![[NSString new] isValidateEmail]; - use this category
    
    
    
//    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}";
//   
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailTest evaluateWithObject:strEmail];
    
    return NO;
}


@end
