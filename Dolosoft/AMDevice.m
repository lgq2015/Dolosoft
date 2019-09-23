//
//  AMDevice.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AMDevice.h"

// https://stackoverflow.com/questions/2484778/anyway-to-get-string-from-variable-name
//#define var_name(arg) (@""#arg)

@implementation AMDevice
- (instancetype)init {
    self = [super init];
    /*
        warning: objc runtime magic incoming!
        this loops through all of AMDevice's properties and assigns the value to each property from the deviceInfoPlist dictionary
     */
    _deviceInfo = [self getDeviceInfo];
    if (!_deviceInfo) {
        return nil;
    }

    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        if ([name isEqualToString:@"deviceInfo"]) {
            // do nothing here because this is not a key in the plist, this is my own property
            continue;
        }
        [self setValue:[_deviceInfo objectForKey:name] forKey:name];
    }
    return self;
}

- (void)printInfo {
    // https://stackoverflow.com/questions/13922581/is-there-a-way-to-log-all-the-property-values-of-an-objective-c-instance
    /*
        warning: objc runtime magic incoming!
        this loops through all of AMDevice's properties and logs them
     */
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        NSLog(@"%@ = %@", name, [self valueForKey:name]);
    }
}

// https://stackoverflow.com/questions/54083843/how-can-i-get-the-ecid-of-a-connected-device-using-libimobiledevice
- (NSDictionary *)getDeviceInfo {
    // https://github.com/libimobiledevice/libimobiledevice/blob/master/tools/ideviceinfo.c
    lockdownd_client_t client = NULL;
    lockdownd_error_t ldret = LOCKDOWN_E_UNKNOWN_ERROR;
    idevice_t device = NULL;
    idevice_error_t ret = IDEVICE_E_UNKNOWN_ERROR;
    int simple = 0;
    const char* udid = NULL;
    char *domain = NULL;
    char *key = NULL;
    char *xml_doc = NULL;
    uint32_t xml_length;
    plist_t node = NULL;
    NSDictionary* plist;
    
    ret = idevice_new(&device, udid);
    if (ret != IDEVICE_E_SUCCESS) {
        if (udid) {
//            printf("No device found with udid %s, is it plugged in?\n", udid);
        } else {
//            printf("No device found, is it plugged in?\n");
        }
        return nil;
    }
    
    if (LOCKDOWN_E_SUCCESS != (ldret = simple ?
                               lockdownd_client_new(device, &client, "ideviceinfo"):
                               lockdownd_client_new_with_handshake(device, &client, "ideviceinfo"))) {
        fprintf(stderr, "ERROR: Could not connect to lockdownd, error code %d\n", ldret);
        idevice_free(device);
        return nil;
    }
    
    /* run query and output information */
    if(lockdownd_get_value(client, domain, key, &node) == LOCKDOWN_E_SUCCESS) {
        if (node) {
            plist_to_xml(node, &xml_doc, &xml_length);
            // https://stackoverflow.com/questions/1072308/parse-plist-nsstring-into-nsdictionary
            NSString *xmlString = [NSString stringWithUTF8String:xml_doc]; // convert char * in NSString *
            NSData* plistData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSPropertyListFormat format;
            plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
            if(!plist){
                NSLog(@"Error: %@",error);
                return nil;
            }
            free(xml_doc);
            plist_free(node);
            node = NULL;
        }
    }
    
    if (domain != NULL)
        free(domain);
    lockdownd_client_free(client);
    idevice_free(device);
    
    if (plist) {
        return plist;
    } else {
        return nil;
    }
}
@end
