
import UIKit






import UIKit

import MaterialComponents

class ApplicationScheme: NSObject {
    
    private static var singleton = ApplicationScheme()
    
    static var shared: ApplicationScheme {
        return singleton
    }
    
    override init() {
        self.buttonScheme.colorScheme = self.colorScheme
        //self.buttonScheme.typographyScheme = self.typographyScheme
        super.init()
    }
    
    public let buttonScheme = MDCButtonScheme()
    
    public let colorScheme: MDCColorScheming = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0);
        
        
        scheme.primaryColorVariant =
            UIColor(red: 0.40, green: 0.85, blue: 1.00, alpha: 1.0);
        
        scheme.onPrimaryColor = .white
            //UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0);
        
        scheme.secondaryColor =
           UIColor(red: 0.32, green: 0.18, blue: 0.66, alpha: 1.0);
        
        scheme.onSecondaryColor =
            UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0);
        scheme.surfaceColor =
            UIColor(red: 0.46, green: 0.64, blue: 0.47, alpha: 1.0);

        scheme.onSurfaceColor =
            UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        scheme.backgroundColor =
            UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        scheme.onBackgroundColor =
            UIColor(red: 68.0/255.0, green: 44.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        scheme.errorColor =
            UIColor(red: 197.0/255.0, green: 3.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        return scheme
    }()
    
}
