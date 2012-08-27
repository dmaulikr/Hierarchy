//
//  HierarchyViewController.h
//  Hierarchy
//
//  Created by Kris Fields on 8/25/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface HierarchyViewController : UIViewController <UITextFieldDelegate, GCTurnBasedMatchHelperDelegate> {
    
    __weak IBOutlet UILabel *statusLabel;
    IBOutlet UITextView *mainTextController;
    IBOutlet UIView *inputView;
    IBOutlet UITextField *textInputField;
    IBOutlet UILabel *characterCountLabel;
}

- (IBAction)sendTurn:(id)sender;

- (IBAction)presentGCTurnViewController:(id)sender;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
- (IBAction)updateCount:(id)sender;
@end
