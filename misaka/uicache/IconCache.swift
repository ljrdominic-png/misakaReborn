//
//  IconCache.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/07.
//

import Foundation
import UniformTypeIdentifiers
import Dynamic
import UIKit

var connectionA: NSXPCConnection?

func RemoveIconCache(alert: Bool) {
    print("removing icon cache")
    if connectionA == nil {
        let myCookieInterface = NSXPCInterface(with: ISIconCacheServiceProtocol.self)
        connectionA = Dynamic.NSXPCConnection(machServiceName: "com.apple.iconservices", options: []).asObject as? NSXPCConnection
        connectionA!.remoteObjectInterface = myCookieInterface
        connectionA!.resume()
        print("Connection: \(connectionA!)")
    }
    
    (connectionA!.remoteObjectProxy as AnyObject).clearCachedItems(forBundeID: nil) { (a: Any, b: Any) in // passing nil to remove all icon cache
        print("Successfully responded (\(a), \(b ?? "(null)"))")
        if alert {
            UIApplication.shared.alert(title: MILocalizedString("Succeed"), body: MILocalizedString("All Caches are deleted"))
        }
    }
}
