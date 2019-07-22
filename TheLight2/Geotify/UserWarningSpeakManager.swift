
import UIKit
import AVFoundation
import Speech

class UserWarningSpeakManager: NSObject {
  
  var speechSynthesizer = AVSpeechSynthesizer()
  static let warning = UserWarningSpeakManager()
  
  override init() {
    super.init()
    speechSynthesizer.delegate = self
  }
  
  func stopSpeaking() {
    // speechSynthesizer.pauseSpeaking(at: .immediate)
    speechSynthesizer.stopSpeaking(at: .immediate)
  }
  
  func startSpeaking(_ speechString: String) {
    let speechUtterance = AVSpeechUtterance(string: speechString)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    speechUtterance.volume = 1.0
    speechUtterance.rate = 0.5
    speechUtterance.pitchMultiplier = 1.15
    
    speechSynthesizer.speak(speechUtterance)
  }
}

extension UserWarningSpeakManager: AVSpeechSynthesizerDelegate{
  public func speechSynthesizer(_ speechSynthesizer: AVSpeechSynthesizer, didFinish utterance:AVSpeechUtterance) {
    print("we finished speaking, so now what to do? oh, startListening again?")
    //try! self.startRecording()
  }
}
