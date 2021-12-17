//
//  Constants.swift
//  SampleOla
//
//  Created by NanoNino on 10/11/21.
//

import Foundation
import UIKit
import Firebase


let kstoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
let db = Firestore.firestore()


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
