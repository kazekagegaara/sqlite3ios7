//
//  sqliteViewController.m
//  SQLiteExample
//
//  Created by Manit on 11/14/14.
//  Copyright (c) 2014 ASU. All rights reserved.
//

#import "sqliteViewController.h"

@interface sqliteViewController ()

@end

@implementation sqliteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to keep the database
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"television.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if([filemgr fileExistsAtPath:_databasePath] == NO){
        const char *dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
            char *errorMessage;
            const char *sql_statement = "CREATE TABLE IF NOT EXISTS survey (ID INTEGER PRIMARY KEY AUTOINCREMENT, PID TEXT, QA TEXT)";
            
            if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK){
                [self showUIAlertWithMessage:@"Failed to create the table" andTitle:@"Error"];
            }
            sqlite3_close(_DB);
        }
        else{
            [self showUIAlertWithMessage:@"Failed to open/create the table" andTitle:@"Error"];
        }
    }
}

-(void) showUIAlertWithMessage:(NSString*)message andTitle:(NSString*) title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(NSDictionary *) getNSDictionaryFromJSON{

    NSString *sampleJSON = @"[{\"question1\" : \"This is question one\",  \"Answer1\" : \"This is answer one\"},{\"question2\" : \"This is question two\",  \"Answer2\" : \"This is answer two\"}]";
    
    NSData *data = [sampleJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    return dict;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)store:(id)sender {
    
    NSDictionary *dict = [self getNSDictionaryFromJSON];
    NSString *qa = [NSString stringWithFormat:@"%@",dict];
    
    qa=[qa stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    NSLog(@"%@",qa);

    NSString *pid = @"1001";
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO survey (pid,qa) VALUES(\"%@\",\"%@\")", pid, qa];
        
        const char *insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE){
            [self showUIAlertWithMessage:@"Added to database" andTitle:@"Success"];
        }
        else{
            [self showUIAlertWithMessage:@"Failed to add the entry" andTitle:@"Error"];
            NSLog(@"Error %s", sqlite3_errmsg(_DB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
}

- (IBAction)showAll:(id)sender {
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];

    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = @"SELECT * FROM survey";
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_DB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *val1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                NSString *val2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *val3 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSLog(@"%@",val1);
                NSLog(@"%@",val2);
                NSLog(@"%@",val3);
            }
        }
    }
    
}

- (IBAction)remAll:(id)sender {
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *query = @"DROP TABLE IF EXISTS survey;";
        const char *sqlStatement = [query UTF8String];
        sqlite3_prepare_v2(_DB, sqlStatement, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE){
            [self showUIAlertWithMessage:@"Table Dropped" andTitle:@"Success"];
        }
        else{
            [self showUIAlertWithMessage:@"Failed" andTitle:@"Error"];
            NSLog(@"Error %s", sqlite3_errmsg(_DB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    
}

@end
