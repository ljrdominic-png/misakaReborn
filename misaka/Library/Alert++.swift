//
//  Alert++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/14.
//

import UIKit
var controller: UIAlertController?

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            controller?.dismiss(animated: animated)
        }
    }
    func textFieldAlert(title: String = MILocalizedString("Error"), message: String, placeholder: String, onOK: @escaping (String) -> (), onCancel: @escaping () -> (), count: Int = 0) {
        DispatchQueue.main.async {
            controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

            // Add a text field to the alert
            controller?.addTextField { textField in
                textField.placeholder = placeholder
            }

            // Add OK action
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak controller] _ in
                if let textField = controller?.textFields?.first, let text = textField.text {
                    onOK(text)
                }
            }
            controller?.addAction(okAction)

            // Add Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                onCancel()
            }
            controller?.addAction(cancelAction)

            self.present(alert: controller!, count: count)
        }
    }
    func alert(title: String = MILocalizedString("Error"), body: String, withButton: Bool = true, count: Int = 0) {
        DispatchQueue.main.async {
            controller = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { controller?.addAction(.init(title: "OK", style: .cancel)) }
            self.present(alert: controller!, count: count)
        }
    }
    func confirmAlert(title: String = MILocalizedString("Error"), body: String, onOK: @escaping () -> (), onCancel: @escaping () -> () = {}, noCancel: Bool = false, count: Int = 0, YesText: String = "Yes", NoText: String = "No") {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            // Check if title is longer than 20 characters
            if title.count > 20 {
                let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                controller.setValue(attributedTitle, forKey: "attributedTitle")
            }
            
            if !noCancel {
                controller.addAction(UIAlertAction(title: MILocalizedString(NoText), style: .cancel, handler: { _ in onCancel() }))
            }
            
            controller.addAction(UIAlertAction(title: MILocalizedString(YesText), style: noCancel ? .cancel : .default, handler: { _ in onOK() }))
            
            self.present(alert: controller, count: count)
        }
    }

    func confirmSelector(title: String, body: String, actions: [UIAlertAction], count: Int = 0) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: body, preferredStyle: .alert)
            for action in actions {
                controller.addAction(action)
            }
            self.present(alert: controller, count: count)
        }
    }
    func actionSheet(title: String?, message: String?, actions: [UIAlertAction], count: Int = 0) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            for action in actions {
                controller.addAction(action)
            }
            self.present(alert: controller, count: count)
        }
    }
    func fileShare(path: URL) {
        DispatchQueue.main.async {
            let controller = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            self.present(alert: controller)
        }
    }
//    func present(alert: UIAlertController, count: Int) {
//        if (PiPController.shared.Loader.path != "") {
//            if var topController = UIApplication.shared.windows.last?.rootViewController {
//                while let presentedViewController = topController.presentedViewController {
//                    topController = presentedViewController
//                }
//                topController.present(alert, animated: true)
//            }
//        }else{
//            if var topController = UIApplication.shared.windows.first?.rootViewController {
//                while let presentedViewController = topController.presentedViewController {
//                    topController = presentedViewController
//                }
//                topController.present(alert, animated: true)
//            }
//        }
//    }
//    func present(alert: UIAlertController, count: Int) {
//        if let mainWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//           let windows = mainWindowScene.windows
//           let sorted = windows.sorted(by: { $0.frame.size.width < $1.frame.size.width })
//            if let rootViewController = sorted[count].rootViewController {
//                rootViewController.present(alert, animated: true)
//            }
//        }
//    }
    func present(alert: UIActivityViewController) {
        if let topViewController = topMostViewController() {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
    func present(alert: UIAlertController, count: Int) {
        if let topViewController = topMostViewController() {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}




func topMostViewController() -> UIViewController? {
    let vc = UIApplication.shared.connectedScenes.filter {
        $0.activationState == .foregroundActive
    }.first(where: { $0 is UIWindowScene })
        .flatMap( { $0 as? UIWindowScene })?.windows
        .first(where: \.isKeyWindow)?
        .rootViewController?
        .topMostViewController()
    return vc
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}
