
import UIKit
import AVFoundation
import Speech

final class UserWarningSpeakManager: NSObject {

    static let warning = UserWarningSpeakManager()
    private var speechSynthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    public func stopSpeaking() {
        // speechSynthesizer.pauseSpeaking(at: .immediate)
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    public func startSpeaking(_ speechString: String) {
        let speech = AVSpeechUtterance(string: speechString)
        speech.voice = AVSpeechSynthesisVoice(language: "en-US")
        speech.volume = 1.0
        speech.rate = 0.5
        speech.pitchMultiplier = 1.15
        speechSynthesizer.speak(speech)
    }
}

extension UserWarningSpeakManager: AVSpeechSynthesizerDelegate{
    public func speechSynthesizer(_ speechSynthesizer: AVSpeechSynthesizer, didFinish utterance:AVSpeechUtterance) {
        print("we finished speaking, so now what to do? oh, startListening again?")
        //try! self.startRecording()
    }
}
