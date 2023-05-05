//
//  BeatDetector.swift
//  StrobeLight
//
//  Created by Jesse Born on 03.05.23.
//

import Foundation
import AVFoundation
import AudioToolbox
import Accelerate


class BeatAnalyzer {
    public let audioEngine = AVAudioEngine()
    let mixerNode = AVAudioMixerNode()
    
    var lastFFTres: [Float] = [1.0, 0.0, 5.0, 0.0]
    
    // Fourier-transform verarbeitet das Signal in einzelne Frequenzen
    //fft setup object for 1024 values going forward (time domain -> frequency domain)
    let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 1024, vDSP_DFT_Direction.FORWARD)
    
    private var ready = false
    
    private func configureAudioEngine() {
        // Get the native audio format of the engine's input bus.
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Set an output format compatible with ShazamKit.
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)
        
        // Create a mixer node to convert the input.
        audioEngine.attach(mixerNode)

        // Attach the mixer to the microphone input and the output of the audio engine.
        audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: inputFormat)
        // audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: outputFormat)
            
        // Install a tap on the mixer node to capture the microphone audio.
        mixerNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: outputFormat) { buffer, audioTime in
            self.processAudioData(buffer: buffer)
        }
        self.ready = true
    }
    func startListening() throws {
        
        if (!self.ready) {
            self.configureAudioEngine()
        }
        
        // Throw an error if the audio engine is already running.
        guard !audioEngine.isRunning else { return }
        let audioSession = AVAudioSession.sharedInstance()
        
        // Ask the user for permission to use the mic if required then start the engine.
        try audioSession.setCategory(.record)
        audioSession.requestRecordPermission { [weak self] success in
            guard success, let self = self else { return }
            try? self.audioEngine.start()
        }
        print("started")
    }
    func stopListening() {
        // Check if the audio engine is already recording.
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
    
    func processAudioData(buffer: AVAudioPCMBuffer){
        guard let channelData = buffer.floatChannelData?[0] else {return}
        // let frames = buffer.frameLength
        
        let fftMagnitudes = SignalProcessing.fft(data: channelData, setup: fftSetup!)
        self.lastFFTres = fftMagnitudes
        print(self.lastFFTres)
        let bins = SignalProcessing.bins(data: fftMagnitudes)
        
        setFlashLevel(_level: bins[0])
    }

}

// https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7
class SignalProcessing {
    
    static func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        //output setup
        var realIn = [Float](repeating: 0, count: 1024)
        var imagIn = [Float](repeating: 0, count: 1024)
        var realOut = [Float](repeating: 0, count: 1024)
        var imagOut = [Float](repeating: 0, count: 1024)

        //fill in real input part with audio samples
        for i in 0...1023 {
            realIn[i] = data[i]
        }
    
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)

        //our results are now inside realOut and imagOut
        
        //package it inside a complex vector representation used in the vDSP framework
        var complex = DSPSplitComplex(realp: &realOut, imagp: &imagOut)
        
        //setup magnitude output
        var magnitudes = [Float](repeating: 0, count: 512)
        
        //calculate magnitude results
        vDSP_zvabs(&complex, 1, &magnitudes, 1, 512)
        
        //normalize
        var normalizedMagnitudes = [Float](repeating: 0.0, count: 512)
        var scalingFactor = Float(25.0/512)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, 512)
        
        return normalizedMagnitudes
    }
    static func bins(data: [Float]) -> [Float] {
        let limits =            [50,   100,  150,  200,    250,   300]
        let bin_size: [Float] =    [50.0, 50.0,  50.0,  50.0,   50.0,  212.0]
        var bins = [Float](repeating: 0.0, count: 6)
        
        var curr_bin = 0
        for i in 0...511 {
            if (i >= limits[curr_bin] && curr_bin < 5) {
                curr_bin += 1
            }
            bins[curr_bin] += data[i] / bin_size[curr_bin]
        }
        
        return bins
    }
}
