//
//  Flash.swift
//  StrobeLight
//
//  Created by Janis Hunziker on 03.05.23.
//

import Foundation
import AVFoundation

class TourchDriver: ObservableObject {
    @Published public var frequency = 0.0
    var active = false
    
    private var timer: Timer?
    private var on = false
    
    func startFlashing() {
        self.active = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/frequency, repeats: true, block: {_ in
            if (self.on) {
                Torch.setTorch(to: 0)
            } else {
                Torch.setTorch(to: 1.0)
            }
            self.on = !self.on
        })
    }
    func stop() {
        self.active = false
        self.timer?.invalidate()
        Torch.setTorch(to: 0.0)
    }
}

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

    private static var currentLevel: Float = 0.0

    private static func device(closure: (AVCaptureDevice) throws -> Void) {
        guard let device = device else { return }
        do {
            try closure(device)
        } catch {
            print("Torch: catch \(error)")
        }
    }
    // Hat das gerät einen Blitz?
    public static func isAvailable() -> Bool {
        return device != nil
    }

    /// Setzt Blitzlicht auf angegebenes Level
    ///
    /// - Parameter level: 0.0 bis 1.0 wobei 0 aus ist und 1 is 100%
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
