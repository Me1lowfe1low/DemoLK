import ReplayKit
import Photos
import Combine

protocol ScreenRecorderManager {
    func isRecording() -> Bool
    func startRecord(with id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func stopRecord()
    func interruptSession()
    func resumeSession()
}

enum RecordingStatus: String {
    case started
    case recording
    case resumed
    case finished
    case interrupted
    case none
}

class ScreenRecorderCoordinator: ObservableObject {
    @Published var buffer: CMSampleBuffer?
    private let screenRecorder = RPScreenRecorder.shared()
    private var status: RecordingStatus = .none
    
    func startDefaultCapture() {
        screenRecorder
            .startCapture(handler: { (sampleBuffer, sampleType, error) in
            print("🦁")
            self.buffer = sampleBuffer
        }) { error in
            print("Error starting capture: \(error?.localizedDescription)")
        }
    }
    
    func stopDefaultCapture() {
        screenRecorder
            .stopCapture(handler: { (error) in
            if let error = error {
                print("Error stopping capture: \(error.localizedDescription)")
            }
        })
    }
    
    private var sharedContainerURL: URL? {
        let fileManager = FileManager.default
        
        if !sessionId.isEmpty {
            let newDirectory = fileManager
                .temporaryDirectory
                .appendingPathComponent("\(sessionId)-desktop")
            try? fileManager.createDirectory(
                at: newDirectory,
                withIntermediateDirectories: false,
                attributes: nil
            )
            
            return newDirectory
        }
        return nil
    }
    
    private var isChunkSaving = false
    private var sessionId = UUID().uuidString
    private var assetWriter: AVAssetWriter?
    private var cancellable = Set<AnyCancellable>()
    private var assetVideoWriterInput: AVAssetWriterInput?
    private var assetAudioWriterInput: AVAssetWriterInput?
    private var time: Double? = nil
    private var lastBufferTime: CMTime? = nil
    private var lastVideoBuffer: CMSampleBuffer?
    
    func isRecording() -> Bool {
        switch status {
            case .started, .recording, .resumed:
                return true
            case .finished, .interrupted, .none:
                return false
        }
    }
    
    func startRecord(
        with id: String
    ){
        sessionId = id
        status = .started
        
//        guard let sharedContainerURL = sharedContainerURL else {
//            print("Unable to get container URL or session id is empty")
//            
//            return
//        }
        
//        try? FileManager.default.removeItem(at: sharedContainerURL)
//        startCapture { result in
//            completion(result)
//        }
        screenRecorder
            .startCapture(handler: { (sampleBuffer, sampleType, error) in
                
                self.buffer = sampleBuffer
            }) { error in
                print("🐯 Error starting capture: \(error?.localizedDescription)")
            }
    }
    
    func stopRecord() {
        status = .finished
        guard screenRecorder.isRecording else {
            print("Screen recorder already stopped")
            
            return
        }
        screenRecorder.stopCapture()
        //recordChunk()
    }
    
//    func interruptSession() {
//        status = .interrupted
//        guard screenRecorder.isRecording else {
//            print("Screen recorder already stopped")
//            
//            return
//        }
//        screenRecorder.stopCapture()
//        recordChunk()
//    }
    
//    func resumeSession() {
//        status = .resumed
//        startCapture()
//    }
    
    private func startCapture(completion: ((Result<Void, Error>) -> Void)? = nil) {
        screenRecorder.startCapture(handler: { [weak self] buffer, bufferType, error in
            guard error == nil,
                  self?.status != .interrupted
            else { return }
            guard self?.time != nil else {
                let timestamp = buffer.presentationTimeStamp.seconds
                self?.time = timestamp
                self?.createScreenRecordWriters(for: timestamp)
                
                return
            }
            self?.lastBufferTime = buffer.presentationTimeStamp
            switch bufferType {
                case .video:
                    self?.lastVideoBuffer = buffer
                    self?.handleVideoSampleBuffer(with: buffer)
                case .audioApp:
                    self?.handleAudioSampleBuffer(with: buffer)
                default:
                    break
            }
            
        }, completionHandler: { error in
            guard let completion else { return }
            guard let error else {
                completion(.success(()))
                return
            }
            
            completion(.failure(error))
        })
    }
    
    private func handleVideoSampleBuffer(with sampleBuffer: CMSampleBuffer) {
        guard let assetVideoWriterInput else { return }
        if assetVideoWriterInput.isReadyForMoreMediaData == true {
            assetVideoWriterInput.append(sampleBuffer)
        }
    }
    
    private func handleAudioSampleBuffer(with sampleBuffer: CMSampleBuffer) {
        guard let assetAudioWriterInput,
              let startTime = time,
              assetWriter?.status == .writing
        else { return }
        let timestamp = sampleBuffer.presentationTimeStamp.seconds
        let time = CMTime(seconds: timestamp - startTime, preferredTimescale: CMTimeScale(600))
        if assetAudioWriterInput.isReadyForMoreMediaData == true {
            assetAudioWriterInput.append(sampleBuffer)
        }
        if CMTimeGetSeconds(time) >= 30 {
           // recordChunk()
        }
    }
    
//    private func recordChunk() {
//        guard !isChunkSaving else { return }
//        
//        guard let url = assetWriter?.outputURL
//        else {
//            print("Unable to get screen chunk URL")
//            return
//        }
//        guard let lastBufferTime else {
//            print("Last buffer time is missing")
//            return
//        }
//        isChunkSaving = true
//        assetVideoWriterInput?.markAsFinished()
//        assetAudioWriterInput?.markAsFinished()
//        
//        assetWriter?.endSession(atSourceTime: lastBufferTime)
//        assetWriter?.finishWriting { [weak self] in
//            self?.isChunkSaving = false
//        }
//        cleanWriters()
//    }
//    
    private func cleanWriters() {
        assetVideoWriterInput = nil
        assetAudioWriterInput = nil
        assetWriter = nil
        time = nil
    }
    
    private func createScreenRecordWriters(for timestamp: Double) {
        guard let videoPath = sharedContainerURL?.appendingPathComponent(
            "video-proctoring\(sessionId)-desktop-\(Int(TimeInterval(Date().timeIntervalSince1970))).mp4"
        ), let writer = try? AVAssetWriter(
            outputURL: videoPath,
            fileType: .mp4
        ) else {
            print("Unable to create AVAssetWriter due problem with output URL")
            return
        }
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: UIScreen.main.bounds.width,
            AVVideoHeightKey: UIScreen.main.bounds.height,
        ]
        
        let videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: videoSettings
        )
        
        videoInput.mediaTimeScale = CMTimeScale(bitPattern: 600)
        videoInput.expectsMediaDataInRealTime = true
        
        let audioSettings : [String : Any] = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVSampleRateKey : 44100,
            AVEncoderBitRateKey : 64000,
            AVNumberOfChannelsKey: 1
        ]
        let audioInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: audioSettings
        )
        
        audioInput.expectsMediaDataInRealTime = true
        
        if writer.canAdd(audioInput), writer.canAdd(videoInput) {
            writer.add(videoInput)
            writer.add(audioInput)
        }
        
        writer.startWriting()
        writer.startSession(atSourceTime: CMTime(seconds: timestamp, preferredTimescale: CMTimeScale(600)))
        if let lastVideoBuffer, let lastBufferTime {
            try? lastVideoBuffer.setOutputPresentationTimeStamp(lastBufferTime)
            videoInput.append(lastVideoBuffer)
        }
        assetWriter = writer
        assetVideoWriterInput = videoInput
        assetAudioWriterInput = audioInput
    }
}
