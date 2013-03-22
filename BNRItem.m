//
//  BNRItem.m
//  RandomPossessions
//
//  Created by Jonathan Ballerano on 2/12/13.
//  Copyright (c) 2013 Jonathan Ballerano. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem

@synthesize itemName, serialNumber, valueInDollars, dateCreated, containedItem, container;
@synthesize imageKey;

+ (id)randomItem
{
    // Create an array of 3 adjectives
    NSArray *randomAdjectiveList =
    [NSArray arrayWithObjects:@"Fluffy", @"Rusty", @"Shiny", nil];

    // Create an array of 3 nouns
    NSArray *randomNounList =
    [NSArray arrayWithObjects:@"Bear", @"Spork", @"Mac", nil];

    // Get index of random adjective / noun from list
    NSInteger adjectiveIndex = rand() % [randomAdjectiveList count];
    NSInteger nounIndex = rand() % [randomNounList count];
    
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]];
    
    int randomValue = rand() % 100;
    
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10];
    
    BNRItem *newItem = [[self alloc] initWithItemName:randomName
                                          valueInDollars:randomValue
                                            serialNumber:randomSerialNumber];
    
    return newItem;
}

- (id)initWithItemName:(NSString *)name
        valueInDollars:(int)value
          serialNumber:(NSString *)sNumber
{
    // Call superclass's designated initializer
    self = [super init];
    
    // Did superclass's designated initializer succeed?
    if (self) {
        // Set initial values
        [self setItemName:name];
        [self setValueInDollars:value];
        [self setSerialNumber:sNumber];
        dateCreated = [[NSDate alloc] init];
    }

    // Return the address of the new object
    return self;
}

- (id)init
{
    return [self initWithItemName:@""
                   valueInDollars:0
                     serialNumber:@""];
}

- (void)setContainedItem:(BNRItem *)i
{
    containedItem = i;
    [i setContainer:self];
}

- (NSString *)description
{
    NSString *descriptionString =
        [[NSString alloc] initWithFormat:@"%@ (%@): Worth $%d, recorded on %@",
         itemName,
         serialNumber,
         valueInDollars,
         dateCreated];
    
    return descriptionString;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:itemName forKey:@"itemName"];
    [aCoder encodeObject:serialNumber forKey:@"serialNumber"];
    [aCoder encodeObject:dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:imageKey forKey:@"imageKey"];
    
    [aCoder encodeInt:valueInDollars forKey:@"valueInDollars"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        itemName = [aDecoder decodeObjectForKey:@"itemName"];
        serialNumber = [aDecoder decodeObjectForKey:@"serialNumber"];
        dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        imageKey = [aDecoder decodeObjectForKey:@"imageKey"];
        
        valueInDollars = [aDecoder decodeIntForKey:@"valueInDollars"];
    }
    return self;

}

//- (void)dealloc
//{
//    NSLog(@"Destroyed: %@", self);
//}

@end
