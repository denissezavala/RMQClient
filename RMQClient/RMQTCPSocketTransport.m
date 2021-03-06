#import "RMQTCPSocketTransport.h"

@interface RMQTCPSocketTransport ()
@property (nonnull, nonatomic, readwrite) NSString *host;
@property (nonnull, nonatomic, readwrite) NSNumber *port;
@property (nonatomic, readwrite) BOOL _isConnected;
@property (nonnull, nonatomic, readwrite) GCDAsyncSocket *socket;
@property (nonnull, nonatomic, readwrite) NSMutableDictionary *callbacks;
@property (nonatomic, copy) void (^onConnectCallback)();
@property (nonatomic, copy) void (^onCloseCallback)();

@end

@implementation RMQTCPSocketTransport

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.host = host;
        self.port = port;
        self.callbacks = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)connect:(void (^)())onConnect {
    NSError *error = nil;
    self.onConnectCallback = onConnect;
    if (![self.socket connectToHost:self.host onPort:self.port.unsignedIntegerValue error:&error]) {
        NSLog(@"*************** Something is very wrong: %@", error);
        self.onConnectCallback = nil;
    }
}

- (void)close:(void (^)())onClose {
    self.onCloseCallback = onClose;
    [self.socket disconnectAfterReadingAndWriting];
}

- (NSString *)write:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error onComplete:(void (^)())complete {
    if (!self._isConnected) {
        *error = [NSError errorWithDomain:@"AMQ"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Not connected", nil)}];
        return nil;
    }
    uint32_t tag = [self generateTag];
    [self.callbacks setObject:[complete copy] forKey:@(tag)];
    [self.socket writeData:data withTimeout:10 tag:tag];
    return @"";
}

struct __attribute__((__packed__)) AMQPHeader {
    UInt8  type;
    UInt16 channel;
    UInt32 size;
};

#define AMQP_HEADER_SIZE 7
#define AMQP_FINAL_OCTET_SIZE 1

- (void)readFrame:(void (^)(NSData * _Nonnull))complete {
    [self read:AMQP_HEADER_SIZE complete:^(NSData * _Nonnull data) {
        const struct AMQPHeader *header;
        header = (const struct AMQPHeader *)data.bytes;
        
        UInt32 hostSize = CFSwapInt32BigToHost(header->size);
        
        [self read:hostSize complete:^(NSData * _Nonnull payload) {
            [self read:AMQP_FINAL_OCTET_SIZE complete:^(NSData * _Nonnull frameEnd) {
                complete(payload);
            }];
        }];
    }];
}

- (void)read:(NSUInteger)len complete:(void (^)(NSData * _Nonnull))complete {
    uint32_t tag = [self generateTag];
    [self.callbacks setObject:[complete copy] forKey:@(tag)];
    [self.socket readDataToLength:len withTimeout:10 tag:tag];
}

- (BOOL)isConnected {
    return self._isConnected;
}

- (uint32_t)generateTag {
    return arc4random_uniform(INT32_MAX);
}

# pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    void (^foundCallback)() = [self.callbacks objectForKey:@(tag)];
    foundCallback(data);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self._isConnected = true;
    self.onConnectCallback();
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self._isConnected = false;
    if (self.onCloseCallback) {
        self.onCloseCallback();
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    void (^foundCallback)() = [self.callbacks objectForKey:@(tag)];
    foundCallback();
}

@end
