//
//  Flash.swift
//  StrobeLight
//
//  Created by Jesse Born on 03.05.23.
//

import Foundation
import AVFoundation


func toggleFlash() {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
    guard device.hasTorch else { return }

    do {
        try device.lockForConfiguration()

        if (device.torchMode == AVCaptureDevice.TorchMode.on) {
            device.torchMode = AVCaptureDevice.TorchMode.off
        } else {
            do {
                try device.setTorchModeOn(level: 1.0)
            } catch {
                print(error)
            }
        }

        device.unlockForConfiguration()
    } catch {
        print(error)
    }
}

func setFlashLevel(_level: Float) {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
    guard device.hasTorch else { return }
    guard _level != 0.0 else {
        killFlash()
        return
    }
    
    var level = _level
    if (_level > 1.0) {
        level = 1.0
    } else if (_level < 0.025) {
        level = 0.0
        killFlash()
        return
    }
    

    do {
        try device.lockForConfiguration()


        do {
            try device.setTorchModeOn(level: level)
        } catch {
            print(error)
        }

        device.unlockForConfiguration()
    } catch {
        print(error)
    }
}

func killFlash() {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
    guard device.hasTorch else { return }

    do {
        try device.lockForConfiguration()

        if (device.torchMode == AVCaptureDevice.TorchMode.on) {
            device.torchMode = AVCaptureDevice.TorchMode.off
        }
        device.unlockForConfiguration()
    } catch {
        print(error)
    }
}

class Flasher {
    public var frequency = 20.0
    var active = false
    
    func startFlashing(atFrequency: Double) {
        self.frequency = 1.0
        
        if (!active) {
            self.active = true
            flash()
        }
        
    }
    func flash() {
        DispatchQueue.main.asyncAfter(deadline:.now() + (1.0/frequency)) {
            toggleFlash()
            
            if (self.active) { self.flash() }
        }
    }
    func stop() {
        self.active = false
        killFlash()
    }
}
