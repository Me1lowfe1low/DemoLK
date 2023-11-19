import AVFoundation
import LiveKit
import ReplayKit

//RPBroadcastSampleHandler
class SampleHandler: LKSampleHandler  {
    public override init()  {
        let appGroupIdentifier = "group.com.DemoLK.lib.DemoLK"
        
        print("🐭 recorder is available", RPScreenRecorder.shared().isAvailable)
    }
}
