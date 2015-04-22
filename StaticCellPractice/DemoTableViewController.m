//
//  DemoTableViewController.m
//  
//
//  Created by Jason Lei on 2015/4/20.
//
//

#import "DemoTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK.h>


@interface DemoTableViewController ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>


@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //==========loading web images=============
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"http://cdn.flaticon.com/png/256/71619.png"]];
    _webImage.image = [UIImage imageWithData: imageData];
    
    NSData * fbImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"http://cdn.flaticon.com/png/256/33702.png"]];
    _fbImage.image = [UIImage imageWithData: fbImageData];
    
    NSData * callImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"http://cdn.flaticon.com/png/256/46854.png"]];
    _callImage.image = [UIImage imageWithData: callImageData];
    //=========================================
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Messages emails and calls
- (IBAction)sendMessage:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc]init];
        [message setSubject:@"Sending Message"];
        [message setRecipients:@[@"0934335299"]];
        message.messageComposeDelegate = self;
        
        [self presentViewController:message animated:YES completion:nil];
    }
    else {
        NSLog(@"error");
    }
}
- (IBAction)sendMail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc]init];
        [mail setSubject:@"Title"];
        [mail setToRecipients:@[@"yitinglei0207@gmail.com"]];
        mail.mailComposeDelegate = self;
        
        
        [self presentViewController:mail animated:YES completion:nil];
        
    }
    else {
        NSLog(@"error");
        
    }
}
- (IBAction)makePhoneCall:(id)sender {
    BOOL result = [[UIApplication sharedApplication] openURL:
                   [NSURL URLWithString:@"tel://0934335299"]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error  {
    //close mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    //close message view
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)openApp:(id)sender {
    BOOL result = [[UIApplication sharedApplication] openURL:
                   [NSURL URLWithString:@"peterPan://"]];
}

- (IBAction)fbLoginAction:(id)sender {
    NSArray *permissionArray = @[ @"user_about_me", @"user_relationships",@"user_birthday",@"email"];
    
    [PFFacebookUtils logInWithPermissions:permissionArray block:^(PFUser *user, NSError *error){
        if(!user){
            NSString *errorMessage = nil;
            if(!error){
                NSLog(@"User cancelled login");
                errorMessage = @"User cancelled login";
            }else{
                NSLog(@"error: %@",error );
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"login error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"dismiss", nil];
            [alert show];
        }else{
            if (user.isNew) {
                NSLog(@"user FB signed up and logged in");
                [self saveUserDataToParse];
            }else{
                NSLog(@"logged in!");
                [self saveUserDataToParse];
            }
            
        }
    }];
}
- (IBAction)fbLogout:(id)sender {
    [PFUser logOut];
    NSLog(@"logged out");
}

-(void) saveUserDataToParse
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            //some people may be make birthday public
            //NSString *birthday = userData[@"birthday"];
            NSString *email =userData[@"email"];
            NSString *pictureURL =[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            NSString *gender =userData[@"gender"];
            
            [[PFUser currentUser] setObject:name forKey:@"name"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebookID"];
            //[[PFUser currentUser] setObject:birthday forKey:@"birthday"];
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] setObject:pictureURL forKey:@"pictureURL"];
            [[PFUser currentUser] setObject:gender forKey:@"gender"];
            
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 2;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
