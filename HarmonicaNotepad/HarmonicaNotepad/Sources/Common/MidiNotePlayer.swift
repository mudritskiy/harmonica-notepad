//
//  MidiNotePlayer.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 28.05.2025.
//

import AVFoundation
import AudioToolbox

class MidiNotePlayer {
    private var audioEngine: AVAudioEngine!
    private var samplerNode: AVAudioUnitSampler!

    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        // Create audio engine and sampler node
        audioEngine = AVAudioEngine()
        samplerNode = AVAudioUnitSampler()

        // Attach sampler to engine
        audioEngine.attach(samplerNode)

        // Set up proper audio format (44.1kHz, stereo)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)

        // Connect sampler to main mixer with explicit format
        audioEngine.connect(samplerNode, to: audioEngine.mainMixerNode, format: format)

        // Configure audio session with better settings
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setPreferredSampleRate(44100)
            try audioSession.setPreferredIOBufferDuration(0.005) // Low latency
            try audioSession.setActive(true)
            print("Audio session configured: Sample Rate = \(audioSession.sampleRate)")
        } catch {
            print("Failed to setup audio session: \(error)")
        }

        // Start the engine
        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error)")
            return
        }

        // Load SoundFont
        loadSoundFont()
    }

    private func loadSoundFont() {
        // https://musical-artifacts.com/artifacts/2633
        guard let soundFontURL = Bundle.main.url(forResource: "harmonica_basic_soundfont", withExtension: "sf2") else {
            print("SoundFont file not found, using default sounds")
            return
        }

        do {
            // Try different loading approaches

            // Method 1: Load specific instrument
            try samplerNode.loadSoundBankInstrument(at: soundFontURL,
                                                    program: 0,
                                                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                    bankLSB: UInt8(kAUSampler_DefaultBankLSB))
            print("SoundFont loaded successfully with Method 1")

        } catch {
            print("Method 1 failed: \(error)")

            // Method 2: Load entire sound bank
            do {
                try samplerNode.loadAudioFiles(at: [soundFontURL])
                print("SoundFont loaded successfully with Method 2")
            } catch {
                print("Method 2 also failed: \(error)")
            }
        }

        // Add a small delay to ensure SoundFont is fully loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("SoundFont loading completed")
        }
    }

    func playNote(note: UInt8, velocity: UInt8 = 127, channel: UInt8 = 0) {
        samplerNode.startNote(note, withVelocity: velocity, onChannel: channel)
    }

    func stopNote(note: UInt8, channel: UInt8 = 0) {
        samplerNode.stopNote(note, onChannel: channel)
    }

    deinit {
        audioEngine?.stop()
    }
}

extension MidiNotePlayer {
    func play(note: HarmonicaNote, velocity: UInt8 = 127, channel: UInt8 = 0) {
        playNote(note: note.midiNote, velocity: note.velocity, channel: channel)
    }

    func stop(note: HarmonicaNote, channel: UInt8 = 0) {
        stopNote(note: note.midiNote, channel: channel)
    }
}
