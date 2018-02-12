//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Patrick on 10/14/17.
//  Copyright © 2017 CodeMobiles. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
