//
//  DataBaseManager.h
//  DataBaseManager
//
//  Created by srivatsa s pobbathi on 02/07/1940 Saka.
//  Copyright © 1940 srivatsa s pobbathi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataBaseManager : NSObject
{
    NSString *path;
    NSString* _dataBasePath;
    sqlite3 *_database;
    BOOL copyDb;
    BOOL ret;
    BOOL status;
    BOOL querystatus;
}
+(DataBaseManager*)dataBaseManager;
-(NSString*) getDBPath;
-(void)openDatabase;
-(BOOL)Create_tbl_dive;
-(BOOL)Create_tbl_pre_temp;
-(BOOL)execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)execute:(NSString*)sqlStatement;
-(int)executeQuerytoGetTableID:(NSString*)sqlStatement;

@end
