//
//  Flash.swift
//  StrobeLight
//
//  Created by Janis Hunziker on 03.05.23.
//

import Foundation
import AVFoundation
import SwiftUI

/// High-Level Klasse zur Steuerung der Taschenlampe mit einer bestimmten Frequenz
class TourchDriver: ObservableObject {
    
    /// Aktuelle Frequenz des Stroboskops
    @Published public var frequency = 0.0
    /// Easter-egg: Gesamtzahl der ausgelösten Blitze.
    @AppStorage("flashes") private var flashCount = 0
    /// Läuft momentan ein Timer der Blitze auslöst?
    private var active = false
    
    /// Timer löst peridosch (stabil) aus.
    private var timer: Timer?
    /// Ein/Aus Status der Taschenlampe
    private var on = false
    
    /// Startet das Blitzen. Plant einen Timer der alle 1.0/Frequenz s auslöst und sich wiederholt.
    func startFlashing() {
        self.active = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/frequency, repeats: true, block: {_ in
            if (self.on) {
                Torch.setTorch(to: 0)
            } else {
                self.flashCount += 1
                Torch.setTorch(to: 1.0)
            }
            self.on = !self.on
        })
    }
    /// Stoppt aktuellen Timer und so das blitzen.
    func stop() {
        self.active = false
        self.timer?.invalidate()
        Torch.setTorch(to: 0.0)
    }
}

/// Hardware Interface. Diese Klasse wird verwendet um die Taschenlampe des Geräts anzusteuern.
/// Sollte das Gerät keinen Blitzer haben (ältere iPads z.B.), stürzt die App nicht ab, da dies überprüft wird.
public class Torch {

    // Funktion die die Rückkamera inkl. Blitz zurückgibt
    private static var sharedDevice: AVCaptureDevice?
    private static var device: AVCaptureDevice? {
        if sharedDevice != nil {
            return sharedDevice
        }
        guard let device = AVCaptureDevice.default(for: .video) else { return nil }
        guard device.hasTorch else { return nil }
        sharedDevice = device
        return device
    }
    /// Nicht aktiv in gebrauch. Wäre gedacht um smooth zu dimmen.
    private static var currentLevel: Float = 0.0

    private static func device(closure: (AVCaptureDevice) throws -> Void) {
        guard let device = device else { return }
        do {
            try closure(device)
        } catch {
            print("Torch: catch \(error)")
        }
    }
    /// Hat das gerät einen Blitz der funktionsbereit ist?
    public static func isAvailable() -> Bool {
        return device != nil
    }

    /// Setzt Blitzlicht auf angegebenes Level
    ///
    /// - Parameter
    ///     - level: 0.0 bis 1.0 wobei 0 aus ist und 1 is 100%
    public static func setTorch(to level: Float) {
        device { device in
            try device.lockForConfiguration()

            if level == 0 {
                device.torchMode = .off
            } else {
                device.torchMode = .on
                try device.setTorchModeOn(level: level)
            }

            currentLevel = level

            device.unlockForConfiguration()
        }
    }
}
