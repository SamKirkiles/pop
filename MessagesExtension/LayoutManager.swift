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
    
    static let iphoneSmallModels:[String] = ["iPod Touch 5","iPod Touch 6","iPhone 5","iPhone 5c","iPhone 5s","iPhone SE","Simulator"]
    static let iphoneLargeModels:[String] = ["iPhone 6", "iPhone 6s Plus","iPhone 6s","iPhone 6 Plus","iPhone 7","iPhone 7 Plus"]
    
    
    static let iphoneSmallLandscapeHeaderSize:CGFloat = 41
    static let iOSRegularLandscapeHeaderSize:CGFloat = 67
    static let iphoneLargeLandscapeHeaderSize:CGFloat = 59
    
    static let iphoneSmallPortraitHeaderSize:CGFloat = 64
    static let iOSRegularPortraitHeaderSize:CGFloat = 86
    static let iphoneLargePortraitHeaderSize:CGFloat = 87
    
    static func getTopInsetAmount(size:CGSize, style:MSMessagesAppPresentationStyle) -> CGFloat{
        if size.height > size.width{
            if style == .expanded{
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                    //expanded portrait ipad
                    return 86
                }else{
                    if #available(iOS 10.2, *){
                        
                        if self.iphoneSmallModels.contains(UIDevice.current.modelName){
                            return iphoneSmallPortraitHeaderSize
                        }else if self.iphoneLargeModels.contains(UIDevice.current.modelName){
                            return iphoneLargePortraitHeaderSize
                        }else{
                            return iOSRegularPortraitHeaderSize
                        }
                    }else{
                        return iOSRegularPortraitHeaderSize
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
                    return iOSRegularPortraitHeaderSize
                }else{
                    if #available(iOS 10.2, *){
                        if self.iphoneSmallModels.contains(UIDevice.current.modelName){
                            return iphoneSmallLandscapeHeaderSize
                        }else if self.iphoneLargeModels.contains(UIDevice.current.modelName){
                            return iphoneLargeLandscapeHeaderSize
                        }else{
                            return iOSRegularLandscapeHeaderSize
                        }
                    }else{
                        return iOSRegularLandscapeHeaderSize
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
                        if self.iphoneSmallModels.contains(UIDevice.current.modelName){
                            return UIEdgeInsets(top: iphoneSmallPortraitHeaderSize, left: 0, bottom: 50, right: 0)
                        }else if self.iphoneLargeModels.contains(UIDevice.current.modelName){
                            return UIEdgeInsets(top: iphoneLargePortraitHeaderSize, left: 0, bottom: 50, right: 0)
                        }else{
                            return UIEdgeInsets(top: iOSRegularPortraitHeaderSize, left: 0, bottom: 50, right: 0)
                        }
                    }else{
                        return UIEdgeInsets(top: iOSRegularPortraitHeaderSize, left: 0, bottom: 50, right: 0)
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
                    return UIEdgeInsets(top: iOSRegularPortraitHeaderSize, left: 0, bottom: 50, right: 0)
                }else{
                    if #available(iOS 10.2, *){
                        if self.iphoneSmallModels.contains(UIDevice.current.modelName){
                            return UIEdgeInsets(top: iphoneSmallLandscapeHeaderSize, left: 0, bottom: 50, right: 0)
                        }else if self.iphoneLargeModels.contains(UIDevice.current.modelName){
                            return UIEdgeInsets(top: iphoneLargeLandscapeHeaderSize, left: 0, bottom: 50, right: 0)
                        }else{
                            return UIEdgeInsets(top: iOSRegularLandscapeHeaderSize, left: 0, bottom: 50, right: 0)
                        }
                    }else{
                        return UIEdgeInsets(top: iOSRegularLandscapeHeaderSize, left: 0, bottom: 50, right: 0)
                    }
                }
            }else{
                return UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }
        }
        
    }
}
