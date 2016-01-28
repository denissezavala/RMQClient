#import <Foundation/Foundation.h>
@import Mantle;

#import "AMQCredentials.h"

@interface AMQProtocolBasicConsumeOk : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;
@property (nonnull, copy, nonatomic, readonly) NSString *consumerTag;
@end

@protocol AMQProtocolFrame <NSObject>
@end

@interface AMQProtocolConnectionStart : MTLModel<NSCoding>

@property (nonnull, copy, nonatomic, readonly) NSNumber *versionMajor;
@property (nonnull, copy, nonatomic, readonly) NSNumber *versionMinor;
@property (nonnull, copy, nonatomic, readonly) NSDictionary<NSObject *, NSObject *> *serverProperties;
@property (nonnull, copy, nonatomic, readonly) NSString *mechanisms;
@property (nonnull, copy, nonatomic, readonly) NSString *locales;

- (nonnull instancetype)initWithVersionMajor:(nonnull NSNumber *)versionMajor
                                versionMinor:(nonnull NSNumber *)versionMinor
                            serverProperties:(nonnull NSDictionary<NSObject *, NSObject *> *)serverProperties
                                  mechanisms:(nonnull NSString *)mechanisms
                                     locales:(nonnull NSString *)locales;

@end

@interface AMQProtocolConnectionStartOk : MTLModel<NSCoding>

- (nonnull instancetype)initWithClientProperties:(nonnull NSDictionary<NSString *, id> *)clientProperties
                                       mechanism:(nonnull NSString *)mechanism
                                        response:(nonnull AMQCredentials *)response
                                          locale:(nonnull NSString *)locale;

@end

@interface AMQProtocolConnectionTuneOk : MTLModel<NSCoding>

- (nonnull instancetype)initWithChannelMax:(nonnull NSNumber *)channelMax
                                  frameMax:(nonnull NSNumber *)frameMax
                                  heartbeat:(nonnull NSNumber *)heartbeat;

@end