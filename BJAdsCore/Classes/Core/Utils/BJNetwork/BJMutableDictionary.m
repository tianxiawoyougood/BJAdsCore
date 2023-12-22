//
//  BJMutableDictionary.m
//  FFFFF
//
//  Created by cc on 2022/4/22.
//

#import "BJMutableDictionary.h"

@implementation BJMutableDictionary {
    /// The mutable dictionary.
    NSMutableDictionary *_objects;

    /// Serial synchronization queue. All reads should use dispatch_sync, while writes use
    /// dispatch_async.
    dispatch_queue_t _queue;
  }

- (instancetype)init {
  self = [super init];

  if (self) {
    _objects = [[NSMutableDictionary alloc] init];
    _queue = dispatch_queue_create("BJMutableDictionary", DISPATCH_QUEUE_SERIAL);
  }

  return self;
}

- (NSString *)description {
  __block NSString *description;
  dispatch_sync(_queue, ^{
    description = self->_objects.description;
  });
  return description;
}

- (id)objectForKey:(id)key {
  __block id object;
  dispatch_sync(_queue, ^{
    object = [self->_objects objectForKey:key];
  });
  return object;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
  dispatch_async(_queue, ^{
    [self->_objects setObject:object forKey:key];
  });
}

- (void)removeObjectForKey:(id)key {
  dispatch_async(_queue, ^{
    [self->_objects removeObjectForKey:key];
  });
}

- (void)removeAllObjects {
  dispatch_async(_queue, ^{
    [self->_objects removeAllObjects];
  });
}

- (NSUInteger)count {
  __block NSUInteger count;
  dispatch_sync(_queue, ^{
    count = self->_objects.count;
  });
  return count;
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key {
  __block id object;
  dispatch_sync(_queue, ^{
    object = self->_objects[key];
  });
  return object;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
  dispatch_async(_queue, ^{
    self->_objects[key] = obj;
  });
}

- (NSDictionary *)dictionary {
  __block NSDictionary *dictionary;
  dispatch_sync(_queue, ^{
    dictionary = [self->_objects copy];
  });
  return dictionary;
}

@end
