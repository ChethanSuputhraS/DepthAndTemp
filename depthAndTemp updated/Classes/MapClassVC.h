//
//  MapClassVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 14/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"

@interface MapClassVC : UIViewController<MKMapViewDelegate>
{
    MKMapView * detailsMap;
}
@property(nonatomic,strong)NSMutableDictionary * detailsDict;
@property BOOL isfromCompared;
@property BOOL isfromSettings;
@property (nonatomic,strong) NSString * strLatitude;
@property (nonatomic,strong) NSString * strLongitude;

@end
