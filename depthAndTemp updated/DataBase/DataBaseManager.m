//
//  DataBaseManager.m
//  DataBaseManager
//
//  Created by srivatsa s pobbathi on 02/07/1940 Saka.
//  Copyright © 1940 srivatsa s pobbathi. All rights reserved.
//

#import "DataBaseManager.h"
static DataBaseManager * dataBaseManager = nil;


@implementation DataBaseManager
-(id) init
{
    self = [super init];
    if (self)
    {
        // get full path of database in documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
        _dataBasePath = [path stringByAppendingPathComponent:@"depthNtemp.sqlite"];
        
        NSLog(@"data base path:%@",path);
        [self openDatabase];
    }
    return self;
    
}
+(DataBaseManager*)dataBaseManager
{
    static dispatch_once_t _singletonPredicate;
    dispatch_once(&_singletonPredicate, ^{
        if (!dataBaseManager)
        {
            dataBaseManager = [[super alloc]init];
        }
    });
    
    return dataBaseManager;
}

- (NSString *) getDBPath
{
    
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"depthNtemp.sqlite"];
    
}
-(void)openDatabase
{
    BOOL ok;
    NSError *error;
    
    /*
     * determine if database exists.
     * create a file manager object to test existence
     *
     */
    NSFileManager *fm = [NSFileManager defaultManager]; // file manager
    ok = [fm fileExistsAtPath:_dataBasePath];
    
    // if database not there, copy from resource to path
    if (!ok)
    {
        // location in resource bundle
        NSString *appPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:@"depthNtemp.sqlite"];
        if ([fm fileExistsAtPath:appPath])
        {
            // copy from resource to where it should be
            copyDb = [fm copyItemAtPath:appPath toPath:_dataBasePath error:&error];
            
            if (error!=nil)
            {
                copyDb = FALSE;
            }
            ok = copyDb;
        }
    }
    
    
    // open database
    if (sqlite3_open([_dataBasePath UTF8String], &_database) != SQLITE_OK)
    {
        sqlite3_close(_database); // in case partially opened
        _database = nil; // signal open error
    }
    
    if (!copyDb && !ok)
    { // first time and database not copied
        ok = [self Create_tbl_dive]; // create empty database
        if (ok)
        {
            // Populating Table first time from the keys.plist
            /*    NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"ads" ofType:@"plist"];
             NSArray *contents = [NSArray arrayWithContentsOfFile:pListPath];
             for (NSDictionary* dictionary in contents) {
             
             NSArray* keys = [dictionary allKeys];
             [self execute:[NSString stringWithFormat:@"insert into ads values('%@','%@','%@')",[dictionary objectForKey:[keys objectAtIndex:0]], [dictionary objectForKey:[keys objectAtIndex:1]],[dictionary objectForKey:[keys objectAtIndex:2]]]];
             }*/
        }
    }
    
    if (!ok)
    {
        // problems creating database
        NSAssert1(0, @"Problem creating database [%@]",
                  [error localizedDescription]);
    }
    
}

#pragma mark - Create Installer Table

-(BOOL)Create_tbl_dive
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'tbl_dive'('dive_id' INTEGER PRIMARY KEY  NOT NULL, 'ble_address' VARCHAR,'dive_no' integer, 'utc_time' VARCHAR, 'gps_latitude' VARCHAR, 'gps_longitude' VARCHAR, 'created_at' VARCHAR, 'updated_at' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}


-(BOOL)Create_tbl_pre_temp
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'tbl_pre_temp' ('pre_temp_id' INTEGER PRIMARY KEY  NOT NULL, 'dive_id' integer,'pressure' VARCHAR, 'utc_time' VARCHAR, 'created_at' VARCHAR, 'updated_at' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}



#pragma mark - SQL query methods
/*
 * Method to get the data table from the database
 */
-(BOOL) execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
    
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
        
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
                
                [row setValue:value forKey:key];
            }
            [dataTable addObject:row];
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}
/*
 * Method to execute the simple queries
 */
-(BOOL)execute:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    return status;
}

-(int)executeQuerytoGetTableID:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    int  returnValue = sqlite3_last_insert_rowid(_database);
    
    return returnValue;
}

@end
