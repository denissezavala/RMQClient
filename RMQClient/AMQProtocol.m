#import "AMQProtocol.h"

@interface AMQProtocolBasicConsumeOk ()
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *consumerTag;
@end

@implementation AMQProtocolBasicConsumeOk

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"consume-ok";
        self.consumerTag = @"amq.ctag.foobar";
    }
    return self;
}

@end

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) NSDictionary<NSObject *, NSObject *> *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) NSString *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) NSString *locales;
@end

@implementation AMQProtocolConnectionStart

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.versionMajor = [coder decodeObjectForKey:@"10_10_version-major"];
        self.versionMinor = [coder decodeObjectForKey:@"10_10_version-minor"];
        self.serverProperties = [coder decodeObjectForKey:@"10_10_server-properties"];
        self.mechanisms = [coder decodeObjectForKey:@"10_10_mechanisms"];
        self.locales = [coder decodeObjectForKey:@"10_10_locales"];
    }
    return self;
}

- (instancetype)initWithVersionMajor:(NSNumber *)versionMajor
                        versionMinor:(NSNumber *)versionMinor
                    serverProperties:(NSDictionary<NSObject *,NSObject *> *)serverProperties
                          mechanisms:(NSString *)mechanisms
                             locales:(NSString *)locales {
    self = [super init];
    if (self) {
        self.serverProperties = serverProperties;
        self.versionMajor = versionMajor;
        self.versionMinor = versionMinor;
        self.mechanisms = mechanisms;
        self.locales = locales;
    }
    return self;
}

@end

@interface AMQProtocolConnectionStartOk ()

@property (nonnull, copy, nonatomic, readwrite) NSDictionary<NSString *, id> *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) NSString *mechanism;
@property (nonnull, copy, nonatomic, readwrite) AMQCredentials *response;
@property (nonnull, copy, nonatomic, readwrite) NSString *locale;

@end

@implementation AMQProtocolConnectionStartOk

- (instancetype)initWithClientProperties:(NSDictionary<NSString *, id> *)clientProperties
                               mechanism:(NSString *)mechanism
                                response:(AMQCredentials *)response
                                  locale:(NSString *)locale {
    self = [super init];
    if (self) {
        self.clientProperties = clientProperties;
        self.mechanism = mechanism;
        self.response = response;
        self.locale = locale;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@{@"type": @"field-table",
                          @"value": self.clientProperties}
                 forKey:@"10_11_client-properties"];
    [coder encodeObject:@{@"type": @"short-string",
                          @"value": self.mechanism}
                 forKey:@"10_11_mechanism"];
    [coder encodeObject:self.response
                 forKey:@"10_11_response"];
    [coder encodeObject:@{@"type": @"short-string",
                          @"value": self.locale}
                 forKey:@"10_11_locale"];
}

@end

@interface AMQProtocolConnectionTuneOk ()

@property (nonnull, copy, nonatomic, readwrite) NSNumber *channelMax;
@property (nonnull, copy, nonatomic, readwrite) NSNumber *frameMax;
@property (nonnull, copy, nonatomic, readwrite) NSNumber *heartbeat;

@end

@implementation AMQProtocolConnectionTuneOk

- (instancetype)initWithChannelMax:(NSNumber *)channelMax
                           frameMax:(NSNumber *)frameMax
                          heartbeat:(NSNumber *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@{@"type": @"short", @"value": self.channelMax}
                 forKey:@"10_30_channel-max"];
    [coder encodeObject:@{@"type": @"long", @"value": self.frameMax}
                 forKey:@"10_30_frame-max"];
    [coder encodeObject:@{@"type": @"short", @"value": self.heartbeat}
                 forKey:@"10_30_heartbeat"];
}

@end