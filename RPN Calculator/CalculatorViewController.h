#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *auxillaryDisplay;
@property (weak, nonatomic) IBOutlet UILabel *debugDisplay;

@property (strong, nonatomic) NSMutableDictionary *testVariableValues;

@end
