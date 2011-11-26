#import "CalculatorBrain.h"

@interface CalculatorBrain ()

@property (nonatomic, strong) NSMutableArray *programStack;

+ (NSString *)descriptionOfTopOfStack:(NSArray *)stack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (_programStack == nil) 
        _programStack = [[NSMutableArray alloc] init];
    
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfTopOfStack:(NSArray *)stack
{
    if (!stack.count)
        return @"";
 
    NSSet *unaryOperations = [NSSet setWithObjects:@"sqrt",@"+/-",
                                                   @"cos",@"sin", nil];
    
    NSSet *twoOperandOperations = [NSSet setWithObjects:@"+",@"-",
                                                        @"/",@"*", nil];
    
    NSSet *variableNames = [NSSet setWithObjects:@"a",@"b",@"x", nil];
    
    NSString *descriptionString;
    
    id topOfStack = [stack lastObject];
    
    NSMutableArray *newStack = [NSMutableArray arrayWithArray:stack];
    [newStack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
        descriptionString = [NSString stringWithFormat:@"%g",
                             [topOfStack doubleValue]];
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        if ([unaryOperations member:topOfStack])
            descriptionString = [NSString stringWithFormat:@"%@(%@)",topOfStack,
                                 [self descriptionOfTopOfStack:newStack]];
        else if ([twoOperandOperations member:topOfStack])
            descriptionString = [NSString stringWithFormat:@"(%@ %@ %@)",
                                 [self descriptionOfTopOfStack:newStack],
                                 topOfStack,
                                 [self descriptionOfTopOfStack:
                                  [newStack subarrayWithRange:
                                   NSMakeRange(0, [newStack count] - 1)]]];
        else if ([variableNames member:topOfStack])
            descriptionString = [topOfStack copy];
    }
    
    return descriptionString;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    
    if ([program isKindOfClass:[NSArray class]] == NO)
        return @"";
    
    NSString *descriptionString = [self descriptionOfTopOfStack:program];
        
    return descriptionString;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) 
                result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sqrt"]) {
            double argument = [self popOperandOffProgramStack:stack];
            result = sqrt(argument);
        } else if ([operation isEqualToString:@"sin"]) {
            double argument = [self popOperandOffProgramStack:stack];
            result = sin(argument);
        } else if ([operation isEqualToString:@"cos"]) {
            double argument = [self popOperandOffProgramStack:stack];
            result = cos(argument);
        } else if ([operation isEqualToString:@"pi"])
            result = M_PI;
        else if ([operation isEqualToString:@"+/-"])
            result = -[self popOperandOffProgramStack:stack];
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
        
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program 
 usingVariableValues:(NSDictionary *)variableValues
{
    return (double)0.0;
}

- (void)restart
{
    self.programStack = nil;
}

@end

