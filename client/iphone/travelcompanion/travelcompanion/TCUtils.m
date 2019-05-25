//
//  TCUtils.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/18/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#import "TCUtils.h"

#import "TCCoreDataController.h"

#define FONT_SIZE 20
#define FONT_HELVETICA @"HelveticaNeue-CondensedBlack"
#define BLACK_SHADOW [UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1]

// API metadata
//TODO: use a different identifier for each of the 3 server environments

NSString *const kAPIVersion = @"1.0";
NSString *const kAPISecret = @"MU3IO2-ABOUK183030190-AUB5678890912";

// host
#if ENV_TYPE == 0
NSString *const kHost = @"https://192.168.1.35";
NSString *const kHostPartial = @"192.168.1.35";
#elif ENV_TYPE == 1
NSString *const kHost = @"https://api.dev.peerflight.com";
NSString *const kHostPartial = @"api.dev.peerflight.com";
#elif ENV_TYPE == 2
NSString *const kHost = @"https://api.staging.peerflight.com";
NSString *const kHostPartial = @"api.staging.peerflight.com";
#else
NSString *const kHost = @"https://api.peerflight.com";
NSString *const kHostPartial = @"api.peerflight.com";
#endif
int const kBasePort = 443;

// realm
NSString *const kBaseRealm = @"Travel Buddy by PeerFlight";

// endpoints
NSString *const kEndPointToken = @"/mobileAuth/login";
NSString *const kEndPointSignup = @"/mobileAuth/signup";

// on app open & active

    //GLOBAL TASK

        // 1-time download
NSString *const kEndPointUsers = @"/mobileUsers/all";

// on app active / inactive (periodic updates)
    // GLOBAL TASKS

        // download NEW user profiles created/updated since <timestamp>
NSString *const kEndPointUsersDate = @"/mobileUsers/all/date/<ts>";

    // USER SPECIFIC TASKS

        // download latest user profile data
NSString *const kEndPointUser = @"/mobileUser/me";

        // upload new (POST)
NSString *const kEndPointUserSettingsNew = @"/mobileUser/settings";
NSString *const kEndPointUserMessageNew = @"/mobileUser/message";
NSString *const kEndPointUserTripNew = @"/mobileUser/trip";
NSString *const kEndPointUserProfileNew = @"/mobileUser/cprofile";

        // upload update (PUT)
NSString *const kEndPointUserSettingsOld = @"/mobileUser/settings";
NSString *const kEndPointUserMessageOld = @"/mobileUser/message/mid>/<mid>";
NSString *const kEndPointUserTripOld = @"/mobileUser/trip/tid/<tid>";
NSString *const kEndPointUserProfileOld = @"/mobileUser/cprofile/pid/<pid>";
// on app going from active --> inactive

// json file refs
NSString *const kJSONPathUsersAll = @"UsersAll";
NSString *const kJSONPathUsersMe = @"UsersMe";

// HTTP codes
NSString *const kHTTPPost = @"POST";

NSString *const kAccountOperationSuccessful = @"AccountOperationSuccessful";
NSString *const kAccountOperationError = @"AccountOperationError";

NSString *const kNJStatusCode = @"NJ-StatusCode";
NSString *const kNJResultSet = @"NJ-ResultSet";

NSString *const kNormalLoginStartNotification = @"NormalLoginStart";
NSString *const kNormalLoginSuccessNotification = @"NormalLoginSuccess";
NSString *const kNormalLoginFailedNotification = @"RegisteredLoginFailed";

NSString *const kSynchCompletedNotification = @"SynchCompleted";

NSString *const kNormalLogoutNotification = @"RegisteredLogout";

NSString *const kNormalSignupStartNotification = @"NormalSignupStart";
NSString *const kNormalSignupSuccessNotification = @"NormalSignupSuccess";
NSString *const kNormalSignupFailedNotification = @"NormalSignupFailed";

// TIMERS
double const kOperationTimeout = 30.0;

// MISC

NSString *const kTripUpdatedNotification = @"TripUpdated";


void doLog(int level, id formatstring,...)
{
    int i;
    for (i = 0; i < level; i++) printf("    ");

    va_list arglist;
    if (formatstring)
    {
        va_start(arglist, formatstring);
        id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
        fprintf(stderr, "%s\n", [outstring UTF8String]);
        va_end(arglist);
    }
}

// this in the implementation
@implementation UIColor (debug)
+ (UIColor *)randomColor
{
    CGFloat red = (arc4random()%256)/256.0;
    CGFloat green = (arc4random()%256)/256.0;
    CGFloat blue = (arc4random()%256)/256.0;
 
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
@end

@implementation UIView (ViewHierarchyLogging)
- (void)logViewHierarchy
{
    DLog(@"%@", self);
    for (UIView *subview in self.subviews)
    {
        subview.backgroundColor = [UIColor randomColor];
        // color nested subviews as well
        for (UIView *nestedsubview in subview.subviews)
        {
            nestedsubview.backgroundColor = [UIColor randomColor];
        }
    }
}
- (void)exploreViewAtLevel:(int)level
{
    doLog(level, @"%@", [[self class] description]);
    doLog(level, @"%@", NSStringFromCGRect([self frame]));
    for (UIView *subview in [self subviews])
        [subview exploreViewAtLevel:(level + 1)];
}
@end

@implementation NSString (CustomAttributedString)
- (NSAttributedString *)customAttributedString
{
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self];
//    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 3)];
////    [attrString addAttribute:NSFontAttributeName value:@"HelveticaNeue-CondensedBlack" range:NSMakeRange(0, [self length])];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont * labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
//    UIColor * labelColor = [UIColor colorWithWhite:1 alpha:1];
//    NSShadow *shadow = [[NSShadow alloc] init];
//    [shadow setShadowColor: BLACK_SHADOW];
//    [shadow setShadowOffset:CGSizeMake (1.0, 1.0)];
//    [shadow setShadowBlurRadius:1];

    NSAttributedString *labelText = [[NSAttributedString alloc] initWithString:self
    attributes:@{
        NSParagraphStyleAttributeName:paragraphStyle,
        NSFontAttributeName : labelFont,
//        NSForegroundColorAttributeName : labelColor,
//        NSShadowAttributeName : shadow
    }];


    return labelText;
}
@end

@implementation TCUtils

+ (BOOL)stringIsNilOrEmpty:(NSString*)aString {
    return !(aString && aString.length && (![aString isEqualToString:@"Detail"]));
}

// Generate a random date sometime between now and n days before day.
// Also, generate a random time to go with the day while we are at it.
+ (NSDate *) generateRandomDateWithinDaysBeforeToday:(int)days
{
    int r1 = arc4random_uniform(days);
    int r2 = arc4random_uniform(23);
    int r3 = arc4random_uniform(59);

    NSDate *today = [NSDate new];
    NSCalendar *gregorian = 
             [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *offsetComponents = [NSDateComponents new];
    [offsetComponents setDay:(r1*-1)];
    [offsetComponents setHour:r2];
    [offsetComponents setMinute:r3];

    NSDate *rndDate1 = [gregorian dateByAddingComponents:offsetComponents 
                                                  toDate:today options:0];

    return rndDate1;
}

+ (void)saveCustomObjectInUserDefaults:(id)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

+ (id)loadCustomObjectFromUserDefaults:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return myobject;
}

#pragma mark Date handling

+ (NSDateFormatter *)initializeDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return dateFormatter;
}

+ (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    if ([TCUtils stringIsNilOrEmpty:dateString])
        return nil;

    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length])];
    
    return [[self initializeDateFormatter] dateFromString:dateString];
}

+ (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    NSString *dateString = [[self initializeDateFormatter] stringFromDate:date];
    // remove Z
//    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length])];
    // add milliseconds and put Z back on
//    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}

#pragma mark Core Data debugger

- (void)debugPersonMO
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", @"guest"];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    
    NSManagedObjectContext *moc = [[TCCoreDataController sharedInstance] parentManagedObjectContext];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc]];
	
	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
	
	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
    
	NSManagedObject *person = nil;
	
	if (fetchResults && [fetchResults count] > 0) {
		// Found record
		person = [fetchResults objectAtIndex:0];
	}
    
//    NSArray *prop = person.entity.properties;
    NSEntityDescription *entity = [person entity];

    NSDictionary *attributes = [entity attributesByName];
    for (NSString *attribute in attributes) {
        id value = [person valueForKey: attribute];
        DLog(@"attribute %@ = %@", attribute, value);
    }
//    for (NSAttributeDescription *attribute in [entity attributesByName])
//    {
//        DLog(@"Attribute = %@, type = %i", attribute, [attribute attributeType]);
//    }
    for (NSPropertyDescription *property in entity)
    {
        DLog(@"Property = %@", property);
    }
    for (NSRelationshipDescription *relationship in entity)
    {
        DLog(@"Relation = %@", relationship);
    }
}

#pragma mark ip handling

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
                            @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
                            @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;

    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);

    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
        {
            address = addresses[key];
            if(address) *stop = YES;
        } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

#pragma mark button styling

+ (void)styleButtons:(UIButton *)button
{
    button.backgroundColor = UIColorFromRGB(0xCAD7BE);
//    button.tintColor = UIColorFromRGB(0x067AB5);
//    button.layer.borderColor = [UIColor blackColor].CGColor;
//    button.layer.borderWidth = 1.0;
//    button.layer.cornerRadius = 10;

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [button setTitleColor:UIColorFromRGB(0x80CCFF) forState:UIControlStateSelected];
}

@end
