//
//  SASigninViewController.m
//  SocialAds
//
//  Created by Muddineti, Dhana (NonEmp) on 12/30/13.
//  Copyright (c) 2013 Social Ads. All rights reserved.
//

#import "SASigninViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SAFacebookHomeViewController.h"

NSString *FACEBOOK_BTN_LOGIN_TITLE = @"Login with Facebook";
NSString *FACEBOOK_BTN_CONTINUE_TITLE = @"Continue with Facebook";

@interface SASigninViewController ()
- (IBAction)handleFacebookLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginBtn;
@property (strong, nonatomic) NSDictionary *userInfo;
- (IBAction)continueAsGuest:(id)sender;

@end

@implementation SASigninViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [self.facebookLoginBtn setTitle:FACEBOOK_BTN_CONTINUE_TITLE forState:UIControlStateNormal];
    } else {
        [self.facebookLoginBtn setTitle:FACEBOOK_BTN_LOGIN_TITLE forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleFacebookLogin:(id)sender {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        //cotinue to next screen
        [self performSegue];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"user_events"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void)performSegue
{
    [self performSegueWithIdentifier:@"FacebookHome" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"FacebookHome"]) {
        SAFacebookHomeViewController *homeController = (SAFacebookHomeViewController*)segue.destinationViewController;
        homeController.userInfo = self.userInfo;
    }
}


// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        [self retrieveUserBasicInfo];
        return;
    }
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }

    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
    [self.facebookLoginBtn setTitle:FACEBOOK_BTN_LOGIN_TITLE forState:UIControlStateNormal];
    
    // Confirm logout message
    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    // Set the button title as "Log out"
    [self.facebookLoginBtn setTitle:FACEBOOK_BTN_CONTINUE_TITLE forState:UIControlStateNormal];

    // Welcome message
//    [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

- (void) retrieveUserBasicInfo
{
    [FBRequestConnection startWithGraphPath:@"/me"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSLog(@"UserInfo: %@", result);
                                  NSDictionary *userInfo = (NSDictionary *) result;
                                  self.userInfo = userInfo;
                                  [self performSegue];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  [self handleError:error];
                              }
                          }];
}

- (void) handleError:(NSError *)error
{
    //Get more error information from the error
    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
    
    // Show the user an error message
    NSString *alertTitle = @"Something went wrong";
    NSString *alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
    [self showMessage:alertText withTitle:alertTitle];
    
}



- (IBAction)continueAsGuest:(id)sender {
    [self performSegueWithIdentifier:@"GuestHome" sender:self];
}
@end

