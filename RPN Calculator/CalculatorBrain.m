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

+ (NSString *)descriptionOfStack:(NSMutableArray *)stack
{
       
    NSMutableString *description;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        description = [NSMutableString stringWithFormat:@"%g",
                       [topOfStack doubleValue]];
    }
    else if ([self isOperation:topOfStack])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) 
            description = [NSMutableString stringWithFormat:@"(%@ + %@)",
                           [self descriptionOfStack:stack],
                           [self descriptionOfStack:stack]];
        else if ([@"*" isEqualToString:operation]) 
            description = [NSMutableString stringWithFormat:@"(%@ * %@)",
                           [self descriptionOfStack:stack],
                           [self descriptionOfStack:stack]];
        else if ([operation isEqualToString:@"-"]) {
            NSString *subtrahendDescription = [self descriptionOfStack:stack];
            
            description = [NSMutableString stringWithFormat:@"(%@ - %@)",
                           [self descriptionOfStack:stack],
                           subtrahendDescription];
        } else if ([operation isEqualToString:@"/"]) {
            NSString *divisorDescription = [self descriptionOfStack:stack];
            
            description = [NSMutableString stringWithFormat:@"(%@/%@)",
                           [self descriptionOfStack:stack],
                           divisorDescription];
        } else if ([operation isEqualToString:@"sqrt"]) 
            description = [NSMutableString stringWithFormat:@"sqrt(%@)",
                           [self descriptionOfStack:stack]];
        else if ([operation isEqualToString:@"sin"])
            description = [NSMutableString stringWithFormat:@"sin(%@)",
                           [self descriptionOfStack:stack]];
        else if ([operation isEqualToString:@"cos"])
            description = [NSMutableString stringWithFormat:@"cos(%@)",
                           [self descriptionOfStack:stack]];
        else if ([operation isEqualToString:@"pi"])
            description = [NSMutableString stringWithString:@"pi"];
        else if ([operation isEqualToString:@"+/-"])
            description = [NSMutableString stringWithFormat:@"-(%@)",
                           [self descriptionOfStack:stack]];
    }
    
    return description;
    
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
    
    return [self descriptionOfStack:stack];
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
