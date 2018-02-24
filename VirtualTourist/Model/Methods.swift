//
//  Methods.swift
//  VirtualTourist
//
//  Created by sam on 2/23/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit

class Helper {
    
    //Mark: - SHow message through Alert
    static func showMessage(title:String,message:String,view:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        //Cancel Button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (actionHandler) in
            alert.dismiss(animated: true, completion: nil)
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
}

