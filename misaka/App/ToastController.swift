//
//  ToastController.swift
//  misaka
//

import SwiftUI
import AlertToast

final class ToastController: ObservableObject {
    static let shared = ToastController()

    @Published var Show_HudLoading = false
    @Published var Toast_HudLoading: AlertToast?

    @Published var Show_Hud = false
    @Published var Toast_Hud: AlertToast?

    @Published var Show_Alert = false
    @Published var Toast_Alert: AlertToast?

    @Published var Show_bannerPop = false
    @Published var Toast_bannerPop: AlertToast?

    @Published var Show_bannerSlide = false
    @Published var Toast_bannerSlide: AlertToast?

    @Published var Show_complete = false
    @Published var Toast_complete: AlertToast?

    @Published var Show_error = false
    @Published var Toast_error: AlertToast?
}
