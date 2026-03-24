//
//  app_exit.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/09.
//

import Foundation
import UIKit

func terminateApp() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(0)
    }
}
