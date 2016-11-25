//
//  LayoutManager.swift
//  pop
//
//  Created by Sam Kirkiles on 11/23/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import Foundation
import UIKit
import Messages

class LayoutManager{
    
    static let iosModels:[String] = ["iPod Touch 5","iPod Touch 6","iPhone 5","iPhone 5c","iPhone 5s","iPhone SE","Simulator"]

    
    static func getTopInsetAmount(size:CGSize, style:MSMessagesAppPresentationStyle) -> CGFloat{
        if size.height > size.width{
            if style == .expanded{
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                    //expanded portrait ipad
                    return 86
                }else{
                    if #available(iOS 10.2, *){
                        
                        if self.iosModels.contains(UIDevice.current.modelName){
                            return 64
                        }else{
                            return 86
                        }
                    }else{
                        return 86
                    }
                 }
            }else{
                //compact
                return 0
            }
        }else{
            if style == .expanded{
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                    //expanded portrait ipad
                    return 86
                }else{
                    if #available(iOS 10.2, *){
                        if self.iosModels.contains(UIDevice.current.modelName){
                            return 41
                        }else{
                            return 67
                        }
                    }else{
                        return 67
                    }
                }
            }else{
                return 0
            }
        }
        
    }

    static func getEdgeInsets(size:CGSize, style:MSMessagesAppPresentationStyle) -> UIEdgeInsets{
    
        if size.height > size.width{
            if style == .expanded{
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                    //expanded portrait ipad
                    return UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
                }else{
                    if #available(iOS 10.2, *){
                        if self.iosModels.contains(UIDevice.current.modelName){
                            return UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
                        }else{
                            return UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
                        }
                    }else{
                        return UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
                    }
                }
            }else{
                //compact
                return UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }
        }else{
            if style == .expanded{
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                    //expanded portrait ipad
                    return UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
                }else{
                    if #available(iOS 10.2, *){
                        if self.iosModels.contains(UIDevice.current.modelName){
                            return UIEdgeInsets(top: 41, left: 0, bottom: 50, right: 0)
                        }else{
                            return UIEdgeInsets(top: 67, left: 0, bottom: 50, right: 0)
                        }
                    }else{
                        return UIEdgeInsets(top: 67, left: 0, bottom: 50, right: 0)
                    }
                }
            }else{
                return UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }
        }
        
    }
}
