//
//  sqliteViewController.h
//  SQLiteExample
//
//  Created by Manit on 11/14/14.
//  Copyright (c) 2014 ASU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface sqliteViewController : UIViewController

@property (strong,nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *DB;

- (IBAction)store:(id)sender;
- (IBAction)showAll:(id)sender;
- (IBAction)remAll:(id)sender;

@end
