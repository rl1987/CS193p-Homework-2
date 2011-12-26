#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsTypingFloatingPointNumber;
@property (nonatomic) BOOL userIsInTheMiddleOfTypingANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSMutableArray *history;

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
@synthesize testVariableValues = _testVariableValues;

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

- (NSMutableDictionary *)testVariableValues
{
    if (!_testVariableValues)
        _testVariableValues = [[NSMutableDictionary alloc] init];
    
    return _testVariableValues;
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
        
    [self.testVariableValues removeAllObjects];
    self.debugDisplay.text = @"";
}

- (IBAction)plusMinusPressed:(UIButton *)sender
{
    
    self.userIsInTheMiddleOfTypingANumber = NO;
    self.userIsTypingFloatingPointNumber = NO;
    
    NSAssert(self.history.count <= kHistoryCapacity,
             @"ERROR: Too much history elements");
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    [self.history addObject: sender.currentTitle];
    
    id result = [CalculatorBrain runProgram:self.history];
    
    if ([result isKindOfClass:[NSNumber class]])
        self.display.text = [NSString stringWithFormat:@"%g",
                             [result doubleValue]];
    else
    {
        UIAlertView *errorPopup = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                             message:result 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Cancel" 
                                                   otherButtonTitles:nil];
        
        [errorPopup show];
        
        return;
    }
    
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
        NSArray *variablesNames = [self.testVariableValues allKeys];
        NSMutableString *debugMessage = [[NSMutableString alloc] init];
        
        for (NSString *variable in variablesNames)
            [debugMessage appendFormat:@"%@ = %g   ",
              variable,[[self.testVariableValues objectForKey:variable] 
                        doubleValue]];
        
        self.debugDisplay.text = debugMessage;
    }
}

- (IBAction)variablePressed:(UIButton *)sender 
{
    NSString *variableName = sender.currentTitle;
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    [self.history addObject: variableName];
    
    self.auxillaryDisplay.text = 
        [CalculatorBrain descriptionOfProgram:self.history];
    
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfTypingANumber)
        [self enterPressed];
    
    NSString *operation = [sender currentTitle];
    
    [self.history addObject:operation];
    
    NSAssert(self.history.count <= kHistoryCapacity,
             @"ERROR: Too much history elements");
    
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    
    id result = [CalculatorBrain runProgram:self.history];
    
    if ([result isKindOfClass:[NSNumber class]])
        self.display.text = [NSString stringWithFormat:@"%g",
                             [result doubleValue]];
    else
    {
        UIAlertView *errorPopup = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                             message:result 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Cancel" 
                                                   otherButtonTitles:nil];
        
        [errorPopup show];
        
        return;
    }
            
    self.auxillaryDisplay.text = 
            [CalculatorBrain descriptionOfProgram:self.history];
}

- (IBAction)test1Pressed 
{
    [self.testVariableValues setObject:[NSNumber numberWithInt:1]
                                forKey:@"a"];
    
    [self.testVariableValues setObject:[NSNumber numberWithInt:2]
                                forKey:@"b"]; 
    
    [self.testVariableValues setObject:[NSNumber numberWithInt:3]
                                forKey:@"c"]; 
    
    id result = [CalculatorBrain runProgram:self.history 
                        usingVariableValues: self.testVariableValues];
    
    if ([result isKindOfClass:[NSNumber class]])
        self.display.text = [NSString stringWithFormat:@"%g",
                             [result doubleValue]];
    else
    {
        UIAlertView *errorPopup = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                             message:result 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Cancel" 
                                                   otherButtonTitles:nil];
        
        [errorPopup show];
        
        return;
    }
    
    [self refreshDebugDisplayIfNeeded];
}

- (IBAction)test2Pressed 
{
    
    [self.testVariableValues setObject:[NSNumber numberWithInt:0]
                                forKey:@"a"];
    
    [self.testVariableValues setObject:[NSNumber numberWithInt:0]
                                forKey:@"b"]; 

    [self.testVariableValues setObject:[NSNumber numberWithInt:0]
                                forKey:@"c"]; 
        
    id result = [CalculatorBrain runProgram:self.history 
                        usingVariableValues:self.testVariableValues];
        
    if ([result isKindOfClass:[NSNumber class]])
        self.display.text = [NSString stringWithFormat:@"%g",
                             [result doubleValue]];
    else
    {
        UIAlertView *errorPopup = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                             message:result 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Cancel" 
                                                   otherButtonTitles:nil];
        
        [errorPopup show];
        
        return;
    }
    
    [self refreshDebugDisplayIfNeeded];    
    
}

- (IBAction)test3Pressed 
{
    
    self.testVariableValues = nil;
    
    id result = [CalculatorBrain runProgram:self.history 
                        usingVariableValues:self.testVariableValues];
    
    if ([result isKindOfClass:[NSNumber class]])
        self.display.text = [NSString stringWithFormat:@"%g",
                             [result doubleValue]];
    else
    {
        UIAlertView *errorPopup = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                             message:result 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Cancel" 
                                                   otherButtonTitles:nil];
        
        [errorPopup show];
        
        return;
    }
    
    [self refreshDebugDisplayIfNeeded];

}

- (IBAction)undoPressed
{
    
    if (self.userIsInTheMiddleOfTypingANumber)
    {
        [self backSpacePressed];
        return;
    }
    
    if ([self.history lastObject])
        [self.history removeLastObject];
    
    self.display.text = [NSString stringWithFormat:@"%g",
                            [CalculatorBrain runProgram:self.history]];
    
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
