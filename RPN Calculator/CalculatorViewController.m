#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsTypingFloatingPointNumber;
@property (nonatomic) BOOL userIsInTheMiddleOfTypingANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSMutableArray *history;
@property (nonatomic, strong) NSMutableDictionary *registers;

#define DEBUG_DISPLAY_ENABLED 1

- (void)refreshDebugDisplayIfNeeded;

@end

@implementation CalculatorViewController

@synthesize display;
@synthesize auxillaryDisplay;
@synthesize debugDisplay;
@synthesize userIsInTheMiddleOfTypingANumber;
@synthesize userIsTypingFloatingPointNumber;
@synthesize brain = _brain;
@synthesize history = _history;
@synthesize registers = _registers;

#define kHistoryCapacity 64 // We're only allowing a limited number of history 
                            // items to be remembered.

- (CalculatorBrain *)brain
{
    if (!_brain)
        _brain = [[CalculatorBrain alloc] init];
        
    return _brain;    
}

- (NSMutableArray *)history
{
    if (!_history)
        _history = [[NSMutableArray alloc] initWithCapacity:kHistoryCapacity];
    
    return _history;
        
}

- (NSMutableDictionary *)registers
{
    if (!_registers)
        _registers = [[NSMutableDictionary alloc] init];
    
    return _registers;
}

- (IBAction)dotPressed 
{
    if (userIsTypingFloatingPointNumber)
        return; // Early bailout - returning if dot was already pressed when
                // typing the number.
    
    self.userIsInTheMiddleOfTypingANumber = YES;
    
    self.userIsTypingFloatingPointNumber = YES;
    self.display.text = [self.display.text stringByAppendingString:@"."];
        
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    
    if (self.userIsInTheMiddleOfTypingANumber)
        self.display.text = [self.display.text stringByAppendingString:digit];
    else
    {
        self.display.text = digit;
        self.userIsInTheMiddleOfTypingANumber = YES;
    }
}

- (IBAction)enterPressed 
{   
    [self.brain pushOperand:[self.display.text doubleValue]];
    
    self.userIsInTheMiddleOfTypingANumber = NO;
    self.userIsTypingFloatingPointNumber = NO;
    
    NSAssert(self.history.count <= kHistoryCapacity,
             @"ERROR: Too much history elements");
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    [self.history addObject: [NSNumber numberWithDouble:
                              [self.display.text doubleValue]]];
    
    self.auxillaryDisplay.text = 
            [CalculatorBrain descriptionOfProgram:self.history];
}

- (IBAction)clearPressed 
{
    [self.brain restart];

    self.history = nil;
    
    self.auxillaryDisplay.text = @"";
    self.display.text = @"0";
    
    self.userIsTypingFloatingPointNumber = NO;
    self.userIsInTheMiddleOfTypingANumber = NO;
        
    [self.registers removeAllObjects];
    self.debugDisplay.text = @"";
}

- (IBAction)plusMinusPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfTypingANumber)
    {
        if ([self.display.text hasPrefix:@"-"])
            self.display.text = [self.display.text substringFromIndex:1];
        else
            self.display.text = 
            [NSString stringWithFormat:@"-%@",self.display.text];
        
        return;
    }
    
    double result = [self.brain performOperation:sender.currentTitle];
    
    self.display.text = [NSString stringWithFormat:@"%g",result];
    
    NSAssert(self.history.count <= kHistoryCapacity,
             @"ERROR: Too much history elements");
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    [self.history addObject: sender.currentTitle];
    
    self.auxillaryDisplay.text = 
            [CalculatorBrain descriptionOfProgram:self.history];
}

- (IBAction)backSpacePressed 
{
    if (!userIsInTheMiddleOfTypingANumber)
        return;
    
    NSInteger length = self.display.text.length;
    
    if (length > 1)
    {
        if ([[self.display.text substringFromIndex:length-1] 
             isEqualToString:@"."])
            self.userIsTypingFloatingPointNumber = NO;
        
        self.display.text = [self.display.text substringToIndex: length-1];
    }
    else
    {
        self.display.text = @"0";
        self.userIsInTheMiddleOfTypingANumber = NO;
    }
}

- (void)refreshDebugDisplayIfNeeded
{
    if (DEBUG_DISPLAY_ENABLED)
    {
        NSArray *variablesNames = [self.registers allKeys];
        NSMutableString *debugMessage = [[NSMutableString alloc] init];
        
        for (NSString *variable in variablesNames)
            [debugMessage appendFormat:@"%@ = %g   ",
              variable,[[self.registers objectForKey:variable] doubleValue]];
        
        self.debugDisplay.text = debugMessage;
    }
}

- (IBAction)variablePressed:(UIButton *)sender 
{
    NSString *variableName = sender.currentTitle;
    
//    [self.registers setObject:[NSNumber numberWithDouble:
//                              [self.display.text doubleValue]] 
//                       forKey:variableName];
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    [self.history addObject: variableName];
    
    self.auxillaryDisplay.text = 
        [CalculatorBrain descriptionOfProgram:self.history];
    
//    [self refreshDebugDisplayIfNeeded];
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfTypingANumber)
        [self enterPressed];
    
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    
    self.display.text = [NSString stringWithFormat:@"%g",result];
    
    NSAssert(self.history.count <= kHistoryCapacity,
             @"ERROR: Too much history elements");
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    [self.history addObject: sender.currentTitle];
    
    self.auxillaryDisplay.text = 
            [CalculatorBrain descriptionOfProgram:self.history];
}

- (void)viewDidUnload 
{
    [self setAuxillaryDisplay:nil];
    [self setDebugDisplay:nil];
    [super viewDidUnload];
}

@end
