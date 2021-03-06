//
//  UIFont+ZBAdditions.swift
//
//  Generated by Zeplin on 10/20/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved. 
//

import UIKit

extension UIFont {
	class func zbTextFont() -> UIFont? {
		return UIFont(name: "ACaslonPro-Regular", size: 9.0)
	}

	class func zbHeadlineFont() -> UIFont? {
		return UIFont(name: "Flama-Basic", size: 9.0)
	}

    class func zbInfoHeadline() -> UIFont? {
        return UIFont(name: "Didot-Italic", size: 28)
    }

    class func zbInfoSubheadline() -> UIFont? {
        return UIFont(name: "DIN-RegularAlternate", size: 18)
    }

    class func zbInfoBody() -> UIFont? {
        return UIFont(name: "Didot", size: 18)
    }
}
