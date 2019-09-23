//
//  AMDevice.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <libimobiledevice/lockdown.h>
#import "AMDeviceManager.h"
#import "AMManager.h"

NS_ASSUME_NONNULL_BEGIN

@class AMDeviceManager, AMManager;

// Honestly wanted to name this class something like AMiOSDevice but that goes against camel case and it bothers me so here we are with AMDevice sorry for the ambiguity
@interface AMDevice : NSObject
- (instancetype)init;
- (void)printInfo;
- (NSDictionary *)getDeviceInfo;
@property(retain, nonatomic) AMManager *manager;
@property(retain, nonatomic) NSDictionary *deviceInfo; /* just to clarify, this isn't some info.plist file which are commonly found on iOS devices.
                                                             this is literally a plist that contains information about the device
                                                            */

// https://en.wikipedia.org/wiki/Property_list
/* property names start with capitals because that's how the keys are spelled in the plist and it makes it easier :) */
@property(retain, nonatomic) NSString *ActivationState;
@property(retain, nonatomic) NSNumber *ActivationStateAcknowledged; // boolean
@property(retain, nonatomic) NSString *BasebandActivationTicketVersion;
@property(retain, nonatomic) NSNumber *BasebandCertId;
@property(retain, nonatomic) NSNumber *BasebandChipID;
@property(retain, nonatomic) NSDictionary *BasebandKeyHashInformation;
//        // AKeyStatus;
//        // SKeyHash;
//        // SKeyStatus;
@property(retain, nonatomic) NSString *BasebandMasterKeyHash;
@property(retain, nonatomic) NSData *BasebandRegionSKU;
@property(retain, nonatomic) NSData *BasebandSerialNumber;
@property(retain, nonatomic) NSString *BasebandStatus;
@property(retain, nonatomic) NSString *BasebandVersion;
@property(retain, nonatomic) NSString *BluetoothAddress;
@property(retain, nonatomic) NSNumber *BoardId;
@property(retain, nonatomic) NSNumber *BrickState; // boolean
@property(retain, nonatomic) NSString *BuildVersion;
@property(retain, nonatomic) NSString *CPUArchitecture;
@property(retain, nonatomic) NSArray *CarrierBundleInfoArray;
//        //    CFBundleIdentifier;
//        //    CFBundleVersion;
//        //    GID1;
//        //    GID2;
//        //    IntegratedCircuitCardIdentity;
//        //    InternationalMobileSubscriberIdentity;
//        //    MCC;
//        //    MNC;
//        //    MobileEquipmentIdentifier;
//        //    SIMGID1;
//        //    SIMGID2;
//        //    Slot;
//        //    kCTPostponementInfoAvailable;
@property(retain, nonatomic) NSNumber *CertID;
@property(retain, nonatomic) NSNumber *ChipID;
@property(retain, nonatomic) NSData *ChipSerialNo;
@property(retain, nonatomic) NSString *DeviceClass;
@property(retain, nonatomic) NSString *DeviceColor;
@property(retain, nonatomic) NSString *DeviceName;
@property(retain, nonatomic) NSNumber *DieID;
@property(retain, nonatomic) NSString *EthernetAddress;
@property(retain, nonatomic) NSString *FirmwareVersion;
@property(retain, nonatomic) NSNumber *FusingStatus;
@property(retain, nonatomic) NSString *GID1;
@property(retain, nonatomic) NSString *GID2;
@property(retain, nonatomic) NSString *HardwareModel;
@property(retain, nonatomic) NSString *HardwarePlatform;
@property(retain, nonatomic) NSNumber *HasSiDP; // boolean
@property(retain, nonatomic) NSNumber *HostAttached; // boolean
@property(retain, nonatomic) NSString *IntegratedCircuitCardIdentity;
@property(retain, nonatomic) NSString *InternationalMobileEquipmentIdentity;
@property(retain, nonatomic) NSString *InternationalMobileEquipmentIdentity2;
@property(retain, nonatomic) NSString *InternationalMobileSubscriberIdentity;
@property(retain, nonatomic) NSNumber *InternationalMobileSubscriberIdentityOverride; // boolean
@property(retain, nonatomic) NSString *MLBSerialNumber;
@property(retain, nonatomic) NSString *MobileEquipmentIdentifier;
@property(retain, nonatomic) NSString *MobileSubscriberCountryCode;
@property(retain, nonatomic) NSString *MobileSubscriberNetworkCode;
@property(retain, nonatomic) NSString *ModelNumber;
@property(retain, nonatomic) NSDictionary *NonVolatileRAM;
//        //    IONVRAM-SYNCNOW-PROPERTY;
//        //    auto-boot;
//        //    backlight-level;
//        //    boot-args;
//        //    bootdelay;
//        //    com.apple.System.tz0-size
@property(retain, nonatomic) NSNumber *PRIVersion_Major;
@property(retain, nonatomic) NSNumber *PRIVersion_Minor;
@property(retain, nonatomic) NSNumber *PRIVersion_ReleaseNo;
@property(retain, nonatomic) NSString *PartitionType;
@property(retain, nonatomic) NSNumber *PasswordProtected; // boolean
@property(retain, nonatomic) NSString *PhoneNumber;
@property(retain, nonatomic) NSData *PkHash;
@property(retain, nonatomic) NSString *ProductName;
@property(retain, nonatomic) NSString *ProductType;
@property(retain, nonatomic) NSString *ProductVersion;
@property(retain, nonatomic) NSNumber *ProductionSOC; // boolean
@property(retain, nonatomic) NSString *ProtocolVersion;
@property(retain, nonatomic) NSData *ProximitySensorCalibration;
@property(retain, nonatomic) NSString *RegionInfo;
@property(retain, nonatomic) NSNumber *SIM1IsEmbedded; // boolean
@property(retain, nonatomic) NSString *ReleaseType;
@property(retain, nonatomic) NSData *SIMGID1;
@property(retain, nonatomic) NSData *SIMGID2;
@property(retain, nonatomic) NSString *SIMStatus;
@property(retain, nonatomic) NSString *SIMTrayStatus;
@property(retain, nonatomic) NSString *SerialNumber;
@property(retain, nonatomic) NSData *SoftwareBehavior;
@property(retain, nonatomic) NSString *SoftwareBundleVersion;
@property(retain, nonatomic) NSArray *SupportedDeviceFamilies;
@property(retain, nonatomic) NSNumber *TelephonyCapability; // boolean
@property(retain, nonatomic) NSNumber *TimeIntervalSince1970;
@property(retain, nonatomic) NSString *TimeZone;
@property(retain, nonatomic) NSNumber *TimeZoneOffsetFromUTC;
@property(retain, nonatomic) NSNumber *TrustedHostAttached; // boolean
@property(retain, nonatomic) NSNumber *UniqueChipID;
@property(retain, nonatomic) NSString *UniqueDeviceID;
@property(retain, nonatomic) NSNumber *UseRaptorCerts; // boolean
@property(retain, nonatomic) NSNumber *Uses24HourClock; // boolean
@property(retain, nonatomic) NSString *WiFiAddress;
@property(retain, nonatomic) NSString *WirelessBoardSerialNumber;
@property(retain, nonatomic) NSNumber *iTunesHasConnected; // boolean
@property(retain, nonatomic) NSString *kCTPostponementInfoPRIVersion;
@property(retain, nonatomic) NSNumber *kCTPostponementInfoPRLName;
@property(retain, nonatomic) NSNumber *kCTPostponementInfoServiceProvisioningState; // boolean
@property(retain, nonatomic) NSString *kCTPostponementStatus;
@end

NS_ASSUME_NONNULL_END
