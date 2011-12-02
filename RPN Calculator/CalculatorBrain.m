#import "CalculatorBrain.h"

@interface CalculatorBrain () /* Private API */

@property (nonatomic, strong) NSMutableArray *programStack;

+ (NSString *)descriptionOfStack:(NSMutableArray *)stack;
+ (BOOL)isOperation:(id)stackElement;

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

+ (BOOL)isOperation:(id)stackElement
{
    if ([stackElement isKindOfClass:[NSString class]] == NO)
        return NO;
    
    NSSet *operations = 
    [NSSet setWithObjects:@"+",@"-",@"/",@"*",@"sqrt",@"+/-",@"cos",@"sin",nil];
    
    if ([operations member:stackElement])
        return YES;
    else 
        return NO;
}

// Program description string is built up recursively.
+ (NSString *)descriptionOfStack:(NSMutableArray *)stack
{
    
    NSMutableString *description;
    
    NSSet *oneOperandOperations = 
    [NSSet setWithObjects:@"sqrt",@"sin",@"cos",@"+/-",nil];
    
    NSSet *twoOperandOperations = 
    [NSSet setWithObjects:@"+",@"*",@"-",@"/",nil];
    
    id topOfStack = [stack lastObject];
    
    if (topOfStack) 
        [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        description = [NSMutableString stringWithFormat:@"%g",
                       [topOfStack doubleValue]];
    }
    else if ([self isOperation:topOfStack])
    {
        if ([twoOperandOperations member:topOfStack])
        {
            if ([topOfStack isEqualToString:@"+"]) {
                if ([twoOperandOperations member:[stack lastObject]]) {
                    description = [NSMutableString stringWithFormat:@"(%@) + ",
                                   [self descriptionOfStack:stack]];
                } 
                else { 
                    description = [NSMutableString stringWithFormat:@"%@ + ",
                                   [self descriptionOfStack:stack]];
                }
                
                if ([twoOperandOperations member:[stack lastObject]]) {
                    [description appendFormat:@"(%@)",
                     [self descriptionOfStack:stack]];
                }
                else 
                    [description appendString:[self descriptionOfStack:stack]];

            } else if ([topOfStack isEqualToString:@"*"]) {
                if ([twoOperandOperations member:[stack lastObject]]) {
                    description = [NSMutableString stringWithFormat:@"(%@) * ",
                                   [self descriptionOfStack:stack]];
                } 
                else { 
                    description = [NSMutableString stringWithFormat:@"%@ * ",
                                   [self descriptionOfStack:stack]];
                }
                
                if ([twoOperandOperations member:[stack lastObject]]) {
                    [description appendFormat:@"(%@)",
                     [self descriptionOfStack:stack]];
                }
                else 
                    [description appendString:[self descriptionOfStack:stack]];                
            } else if ([topOfStack isEqualToString:@"-"]) {
                NSString *subtrahendDescription;
                
                if ([twoOperandOperations member: [stack lastObject]])
                    subtrahendDescription = 
                    [NSString stringWithFormat:@"(%@)",
                     [self descriptionOfStack:stack]];
                else 
                    subtrahendDescription=[self descriptionOfStack:stack];
                
                if ([twoOperandOperations member: [stack lastObject]]) {
                    description = [NSMutableString stringWithFormat:@"(%@) - %@",
                                   [self descriptionOfStack:stack],
                                   subtrahendDescription];
                } else {
                    description = [NSMutableString stringWithFormat:@"%@ - %@",
                                   [self descriptionOfStack:stack],
                                   subtrahendDescription];
                }
                
            } else if ([topOfStack isEqualToString:@"/"]) {
                NSString *divisorDescription;
                
                if ([twoOperandOperations member: [stack lastObject]])
                    divisorDescription = 
                    [NSString stringWithFormat:@"(%@)",
                     [self descriptionOfStack:stack]];
                else 
                    divisorDescription=[self descriptionOfStack:stack];
                
                if ([twoOperandOperations member: [stack lastObject]]) {
                    description = [NSMutableString stringWithFormat:@"(%@) / %@",
                                   [self descriptionOfStack:stack],
                                   divisorDescription];
                } else {
                    description = [NSMutableString stringWithFormat:@"%@ / %@",
                                   [self descriptionOfStack:stack],
                                   divisorDescription];
                }

            } 
        }
        else if ([oneOperandOperations member:topOfStack])
        {
            if ([topOfStack isEqualToString:@"sqrt"]) {
                description = [NSMutableString stringWithFormat:@"sqrt(%@)",
                               [self descriptionOfStack:stack]];
            } else if ([topOfStack isEqualToString:@"sin"]) {
                description = [NSMutableString stringWithFormat:@"sin(%@)",
                               [self descriptionOfStack:stack]];
            } else if ([topOfStack isEqualToString:@"cos"]) {
                description = [NSMutableString stringWithFormat:@"cos(%@)",
                               [self descriptionOfStack:stack]];
            } else if ([topOfStack isEqualToString:@"+/-"]) {
                description = [NSMutableString stringWithFormat:@"-(%@)",
                               [self descriptionOfStack:stack]];
            }
        } 
        else if ([topOfStack isEqualToString:@"pi"])
            description = [NSMutableString stringWithString:@"pi"];
        
    }
    else 
        description = [[NSMutableString alloc] initWithString:@""];
    
    return description;
    
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSMutableString *result = [[NSMutableString alloc] init];
    
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];

    do {
        [result appendString:[self descriptionOfStack:stack]];
        
        if ([stack count])
            [result appendString:@", "];
    } while ([stack count]);
    
    return result;
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
    double result = 0.0;
    
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
