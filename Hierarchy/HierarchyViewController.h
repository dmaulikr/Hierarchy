//
//  HierarchyViewController.h
//  Hierarchy
//
//  Created by Kris Fields on 8/25/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface HierarchyViewController : UIViewController <UITextFieldDelegate, GCTurnBasedMatchHelperDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    __weak IBOutlet UILabel *statusLabel;
    IBOutlet UITextField *textInputField;
    
}
@property (weak, nonatomic) IBOutlet UITableView *playersToKill;


- (IBAction)presentGCTurnViewController:(id)sender;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
@end
