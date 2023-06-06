//
//  BeatDetector.swift
//  StrobeLight
//
//  Created by Jesse Born on 03.05.23.
//

import Foundation
import AVFoundation
import Accelerate
import ShazamKit

/// Diese Klasse bietet die nötige Infrastruktur um:
///     - Mikrofonberechtigung einzuholen
///     - Eine Audiositzung aufzubauen
///     - Audio mittels Fourier Transformation in einzene Frequenz umzuwandeln
///     - Frequenzbereiche in "Bins" zu packen (Frequenzbereiche zusammenfassen)
///     - Derivate des untersten Bins berechnen (Änderungsrate berechnen)
///     - S_1-Intervall des Derivates zu bestimmen
///     - Bei überstreitung des S_1-Intervalls einen Blitz auszulösen
///     TL;DR: Blitze auf Beats getimet auszulösen. 
class BeatAnalyzer: ObservableObject {
    /// Empfängt Audiodaten vom System
    public let audioEngine = AVAudioEngine()
    /// AVAudioEngine arbeitet mit einer Art Graph. Diese Node wird verwendet für unsere Verarbeitung
    let mixerNode = AVAudioMixerNode()
    let shazamNode = AVAudioMixerNode()
    
    /// Letztes Resultat des Fourier-Transfromationsschrittes
    var lastFFTres: [Float] = [1.0, 0.0, 5.0, 0.0]
    /// Letztes Resultat des Binning-Schrittes
    var lastBinsres: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    /// Letzte Änderungsraten der Lautstärke der Bins
    var lastBinsDerivative: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    
    /// Durchschnittliche Lautstärke des 1. Bins (tiefste Frequenz)
    var avg_value = Float(0.0)
    /// n für die Durchschnittsberechnung
    var avg_cnt = Float(1.0)
    /// Standartabweichung (s 1-Intervall) der Lautstärke im 1. Bin
    var avg_dev = Float(0.0)
    
    /// Speicherallocation für simultanvektorbasiertes Fast-Fourier-Transform im komplexen Raum
    let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 1024, vDSP_DFT_Direction.FORWARD)
    
    /// ShazamKit integration
    var matchingHelper: MatchingHelper?
    @Published var lastShazamMatch: SHMatchedMediaItem?
    
    private var ready = false
    
    /// Initialisert Audiocodec und Verarbeitungspipeline sowie nötige Buffer
    private func configureAudioEngine() {
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)

        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)

        audioEngine.attach(mixerNode)
        audioEngine.attach(shazamNode)


        audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: inputFormat)
        audioEngine.connect(mixerNode, to: shazamNode, format: inputFormat)
        
        mixerNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: outputFormat) { buffer, audioTime in
//            print("call hand")
            self.processAudioData(buffer: buffer)
        }
        
        
        
        // Shazam
        
        self.matchingHelper = MatchingHelper { MediaItem, error in
            print("matched song: \(MediaItem?.title ?? "--")")
            self.lastShazamMatch = MediaItem
        }
        self.matchingHelper?.session = SHSession()
        self.matchingHelper?.setDelegate()
        shazamNode.installTap(onBus: 0, bufferSize: 2048, format: outputFormat) { buffer, audioTime in
//            print("call shzam")
            self.matchingHelper?.session?.matchStreamingBuffer(buffer, at: audioTime)
        }
        self.ready = true
    }
    /// Startet eine Audiosession (übernimmt das Mikrofon) und hängt den Verarbeitungsgraphen an.
    func startListening() throws {
        
        if (!self.ready) {
            self.configureAudioEngine()
        }
        
        // Falls die AudioEngine schon läuft abbrechen
        guard !audioEngine.isRunning else { return }
        let audioSession = AVAudioSession.sharedInstance()
        
        // Nutzer nach Berechtigung fragen
        try audioSession.setCategory(.record, options: .mixWithOthers)
        audioSession.requestRecordPermission { [weak self] success in
            guard success, let self = self else { return }
            try? self.audioEngine.start()
        }
        print("started")
    }
    /// Stoppt die Verarbeitung von Audio
    func stopListening() {
        // Engine stoppen wenn diese läuft
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
    /// Circa alle 100ms wird dieses Callback mit einem 1024 Werte langem Audiobuffer aufgerufen.
    /// Hier werden Mikrofondaten vom Systemtreiber übernommen, analysiert und ausgewertet
    func processAudioData(buffer: AVAudioPCMBuffer){
        guard let channelData = buffer.floatChannelData?[0] else {return}
        /// FFT Schritt. Frequenzen die im Audiosignal zu finden sind werden Isoliert
        let fftMagnitudes = SignalProcessing.fft(data: channelData, setup: fftSetup!)
        self.lastFFTres = fftMagnitudes
        
        /// Frequenzen zu Bins zusammenfassen
        let bins = SignalProcessing.bins(data: fftMagnitudes)
        /// Änderungsraten berechnen
        self.lastBinsDerivative = SignalProcessing.derivative(data: bins, old_data: lastBinsres)
        
        lastBinsres = bins
        
        /// Durchschnittliche Lautstärke (effizient) fortlaufend berechnen
        avg_cnt += 1
        let total = (avg_value*(avg_cnt - 1.0))
                     
        avg_value = (total+lastBinsDerivative[0])/avg_cnt
        
        let total_deviation = avg_dev*(avg_cnt - 1.0)
        avg_dev = (total_deviation + (abs(lastBinsDerivative[0]) - avg_value))/avg_cnt
        
        /// Übersteigt das Derivat der Lautstärke die 1.5x Standardabweichung, wird das Blitzlicht ausgelöst
        let value = lastBinsDerivative[0] > avg_dev*1.5 ? Float(1.0) : 0.0
//        print("avg \(avg_value) std dev \(avg_dev)")
        Torch.setTorch(to: value)
    }

}
/// Utility-Klasse, die Abstracktionen zur Signalverarbeitung zur verfügung stellt. u.A. lebt hier die GPU-beschleunigte FFT, Frequentbinning, Derivatsberechnung und Blitzauslösung
class SignalProcessing {
    
    static func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        // Setup output
        var realIn = [Float](repeating: 0, count: 1024)
        var imagIn = [Float](repeating: 0, count: 1024)
        var realOut = [Float](repeating: 0, count: 1024)
        var imagOut = [Float](repeating: 0, count: 1024)

        // PLatzhalter einfüllen
        for i in 0...1023 {
            realIn[i] = data[i]
        }
    
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)

        var complex = DSPSplitComplex(realp: &realOut, imagp: &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: 512)
        
        vDSP_zvabs(&complex, 1, &magnitudes, 1, 512)
        
        // Daten normalisieren
        var normalizedMagnitudes = [Float](repeating: 0.0, count: 512)
        var scalingFactor = Float(25.0/512)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, 512)
        
        return normalizedMagnitudes
    }
    static func bins(data: [Float]) -> [Float] {
        let limits =            [10,   20,  30,  50,    150,   300]
        let bin_size: [Float] =    [10.0, 10.0,  20.0,  100.0,   150.0,  212.0]
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
    
    static func derivative(data: [Float], old_data: [Float]) -> [Float] {
        var derivative: [Float] = []
        for i in 0...5 {
            derivative.append(old_data[i] - data[i])
        }
        return derivative
    }
}
