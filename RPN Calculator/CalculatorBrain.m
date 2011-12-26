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
    [NSSet setWithObjects:@"+",@"-",@"/",@"*",@"sqrt",@"+/-",@"cos",@"sin",
                            @"pi",nil];
    
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
    
    NSSet *variableNames = [NSSet setWithObjects:@"a",@"b",@"c", nil];
    
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
            if ([topOfStack isEqualToString:@"+"] || 
                [topOfStack isEqualToString:@"*"]) 
            {
                if ([twoOperandOperations member:[stack lastObject]]) {
                    description = [NSMutableString stringWithFormat:@"(%@) %@ ",
                                   [self descriptionOfStack:stack],topOfStack];
                } 
                else { 
                    description = [NSMutableString stringWithFormat:@"%@ %@ ",
                                   [self descriptionOfStack:stack],topOfStack];
                }
                
                if ([twoOperandOperations member:[stack lastObject]]) {
                    [description appendFormat:@"(%@)",
                     [self descriptionOfStack:stack]];
                }
                else 
                    [description appendString:[self descriptionOfStack:stack]];
            } else if ([topOfStack isEqualToString:@"-"] || 
                       [topOfStack isEqualToString:@"/"]) 
            {
                NSString *firstArgumentDescription;
                NSString *secondArgumentDescription;
                
                if ([twoOperandOperations member: [stack lastObject]])
                    secondArgumentDescription = [NSString stringWithFormat:@"(%@)",
                                                 [self descriptionOfStack:stack]];
                else
                    secondArgumentDescription = [NSString stringWithFormat:@"%@",
                                                 [self descriptionOfStack:stack]];                    
                
                if ([twoOperandOperations member: [stack lastObject]])
                    firstArgumentDescription = [NSString stringWithFormat:@"(%@)",
                                                [self descriptionOfStack:stack]];
                else
                    firstArgumentDescription = [NSString stringWithFormat:@"%@",
                                                [self descriptionOfStack:stack]];
                
                description = [NSString stringWithFormat:@"%@ %@ %@",
                               firstArgumentDescription,topOfStack,
                               secondArgumentDescription];

            } 
        }
        else if ([oneOperandOperations member:topOfStack])
        {
            if ([topOfStack isEqualToString:@"+/-"]) 
                description = [NSMutableString stringWithFormat:@"-(%@)",
                               [self descriptionOfStack:stack]];
            else 
                description = [NSMutableString stringWithFormat:@"%@(%@)",
                               topOfStack,[self descriptionOfStack:stack]];
        } 
        else if ([topOfStack isEqualToString:@"pi"])
            description = [NSMutableString stringWithString:@"pi"];
        
    }
    else if ([variableNames member:topOfStack])
        description = [topOfStack copy];
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

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (id)popOperandOffProgramStack:(NSMutableArray *)stack
{
    id result;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = topOfStack;
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            double component1,component2;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                component1 = [arg1 doubleValue];
            else
                return arg1;
            
            id arg2 = [self popOperandOffProgramStack:stack];
            
            if ([arg2 isKindOfClass:[NSNumber class]])
                component2 = [arg2 doubleValue];
            else
                return arg2;
            
            result = [NSNumber numberWithDouble:component1+component2];
        } else if ([@"*" isEqualToString:operation]) {
            double factor1,factor2;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                factor1 = [arg1 doubleValue];
            else
                return arg1;
            
            id arg2 = [self popOperandOffProgramStack:stack];
            
            if ([arg2 isKindOfClass:[NSNumber class]])
                factor2 = [arg2 doubleValue];
            else
                return arg2;    
            
            result = [NSNumber numberWithDouble:factor1*factor2];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend,minuend;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                subtrahend = [arg1 doubleValue];
            else
                return arg1;
            
            id arg2 = [self popOperandOffProgramStack:stack];
            
            if ([arg2 isKindOfClass:[NSNumber class]])
                minuend = [arg2 doubleValue];
            else
                return arg2;

            result = [NSNumber numberWithDouble:minuend - subtrahend];
        } else if ([operation isEqualToString:@"/"]) {
            double dividend,divisor;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                dividend = [arg1 doubleValue];
            else
                return arg1;
            
            id arg2 = [self popOperandOffProgramStack:stack];
            
            if ([arg2 isKindOfClass:[NSNumber class]])
                divisor = [arg2 doubleValue];
            else
                return arg2;            
            
            if (divisor) 
                result = [NSNumber numberWithDouble:dividend/divisor];
            else
                return @"Division by zero.";
        } else if ([operation isEqualToString:@"sqrt"]) {
            double argument;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                argument = [arg1 doubleValue];
            else
                return arg1;
            
            if (argument>=0)
                result = [NSNumber numberWithDouble:sqrt(argument)];
            else 
                result = @"Square root of negative number.";
        } else if ([operation isEqualToString:@"sin"]) {
            double argument;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                argument = [arg1 doubleValue];
            else
                return arg1;
            
            result = [NSNumber numberWithDouble:sin(argument)];
        } else if ([operation isEqualToString:@"cos"]) {
            double argument;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                argument = [arg1 doubleValue];
            else
                return arg1;
            
            result = [NSNumber numberWithDouble:cos(argument)];
        } else if ([operation isEqualToString:@"pi"])
            result = [NSNumber numberWithDouble: M_PI];
        else if ([operation isEqualToString:@"+/-"]) {
            double argument;
            
            id arg1 = [self popOperandOffProgramStack:stack];
            
            if ([arg1 isKindOfClass:[NSNumber class]])
                argument = [arg1 doubleValue];
            else
                return arg1;
            
            result = [NSNumber numberWithDouble:-argument];
        }
    }
    
    return result;
}

+ (id)runProgram:(id)program
{
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
        
    id result = [self popOperandOffProgramStack:stack];
    
    if (result)
        return result;
    else
        return @"Not enough arguments.";
}

+ (id)runProgram:(id)program 
 usingVariableValues:(NSDictionary *)variableValues
{
    
    if (program == nil)
        return @"No program defined.";
    
    if (variableValues == nil)
        return @"No variables defined.";
    
    NSSet *usedVariables = [self variablesUsedInProgram:program];
    
    NSMutableArray *programWithNumbers = [program mutableCopy];
    
    for (short int i=0; i<[programWithNumbers count]; i++)
    {
        id elementInQuestion = [[programWithNumbers objectAtIndex:i] copy];
        
        if ([usedVariables member:elementInQuestion])
        {
            NSNumber *value = [variableValues objectForKey:elementInQuestion];
            
            if (value == nil)
                value = [NSNumber numberWithInt:0];
            
            [programWithNumbers replaceObjectAtIndex:i 
                                          withObject:value];
        }
                                                                   
    }
       
    id result = [self runProgram:programWithNumbers];
    
    if (result)
        return result;
    else
        return @"Not enough arguments.";
    
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
   
    NSSet *variableNames = [NSMutableSet setWithObjects:@"a",@"b",@"c",nil];
    NSMutableSet *result = [[NSMutableSet alloc] init];
    
    for (short int i=0; i<[program count]; i++)
        if ([variableNames member:[program objectAtIndex:i]])
            [result addObject:[program objectAtIndex:i]];
        
    return [result copy];
}

- (void)restart
{
    self.programStack = nil;
}

@end
