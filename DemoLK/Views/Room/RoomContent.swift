import SwiftUI
import CoreMedia
import LiveKit
import Combine

import CoreGraphics
import VideoToolbox


struct RoomContent: View {
    @EnvironmentObject var applicationContext: AppContext
    @EnvironmentObject var roomContext: RoomContext
    @EnvironmentObject var room: Room
    
    @State var geometry: GeometryProxy
    
    
    @ObservedObject var screenRecorderCoordinator = ScreenRecorderCoordinator()
    @ObservedObject var screenRecorderManager = TempRecordingManager()
        //    var cameraPreviewPublisher: AnyPublisher<CMSampleBuffer?, Never>?
    @State var screenBuffer: CMSampleBuffer?
    @State var videoBuffer: CurrentValueSubject<CMSampleBuffer?, Never>?
//    @State var buffer: CMSampleBuffer?
    @State var sessionID = UUID().uuidString
    @State private var image: CGImage?
    @Binding var shareScreenOpened: Bool
    
    var body: some View {
        VStack {
            AdaptiveStack(
                axis: geometry.isTall ? .vertical : .horizontal,
                spacing: stackSpacing
            ) {
                Group {
                    if let focusParticipant = roomContext.focusParticipant {
                        ZStack(alignment: .bottomTrailing) {
                            ParticipantView(
                                participant: focusParticipant,
                                videoViewMode: applicationContext.videoViewMode
                            ) { _ in
                                roomContext.focusParticipant = nil
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: overlayCornerRadius)
                                    .stroke(
                                        overlayBorderColor
                                            .opacity(overlayBorderColorOpacity),
                                        lineWidth: overlayBorderWidth
                                    )
                            )
                        }
                    } else {
                        ParticipantLayout(
                            sortedParticipants(),
                            spacing: layoutSpacing
                        ) { participant in
                            ParticipantView(
                                participant: participant,
                                videoViewMode: applicationContext.videoViewMode
                            ) { participant in
                                roomContext.focusParticipant = participant
                            }
                        }
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                
                if roomContext.showMessagesView {
                    MessagesView(geometry: geometry)
                }
                
                if roomContext.showStreamView {
//                if shareScreenOpened {
//                    Text("\(shareScreenOpened.description)")
                    Text("\(roomContext.showStreamView.description)")
                    
                    ScreenShareImageView(currentFrameImage: $image)
                        .frame(
                            width: 300,
                            height: 300
                        )
                        .onReceive(currentImage) { img in
                            print("🐣 image changed")
                            image = img
                        }
                        .onReceive(roomContext.$showStreamView) { value in
//                        .onChange(of: Just($shareScreenOpened.wrappedValue)) { value in
//                        .onReceive(Just($shareScreenOpened.wrappedValue)) { value in
                            print("🐹 buffer: \(value), roomContext.shareStatus: \(roomContext.shareStatus) ")
                            if value == true && roomContext.shareStatus != .started {
                                print("🐹 start, roomContext.shareStatus: \(roomContext.shareStatus)  ")
                                roomContext.shareStatus = .started
//                                startRecord()
                                screenRecorderCoordinator.startRecord(with: sessionID)
                            } else if value == false {
                                print("🐹 stop, roomContext.shareStatus: \(roomContext.shareStatus) ")
                                roomContext.shareStatus = .stopped
//                                stopRecord()
                                screenRecorderCoordinator.stopRecord()
                            } else {
                                print("Smth, roomContext.shareStatus: \(roomContext.shareStatus) ")
                            }
                        }
                        
                }
            }
        }
        .padding(5)
    }
    
    var currentImage: AnyPublisher<CGImage?, Never> {
        guard let tempVideoBuffer = videoBuffer else {
            let imageSubject = CurrentValueSubject<CGImage?, Never>(nil)
            
            return imageSubject.eraseToAnyPublisher()
        }
        
        return screenRecorderCoordinator.videoBuffer
            .print("🐴 Buffer")
            .receive(on: DispatchQueue.main)
            .compactMap {
                guard let imageBuffer = $0?.imageBuffer,
                      let cgImage = imageBuffer.toCGImage()
                else { return nil }
                
                return cgImage
            }
            .eraseToAnyPublisher()
    }
}

private let overlayCornerRadius: CGFloat = 4.0
private let overlayBorderColor: Color = .red
private let overlayBorderColorOpacity: CGFloat = 0.7
private let overlayBorderWidth: CGFloat = 1.0
private let stackSpacing: CGFloat = 5.0
private let layoutSpacing: CGFloat = 5.0

extension RoomContent {
    private func sortedParticipants() -> [Participant] {
        room.allParticipants.values.sorted { p1, p2 in
            if p1 is LocalParticipant { return true }
            if p2 is LocalParticipant { return false }
            return (p1.joinedAt ?? Date()) < (p2.joinedAt ?? Date())
        }
    }
    
    public func startRecord() {
        screenRecorderManager.startRecord(with: sessionID) { result in
            switch result {
                case .success():
                    screenRecorderManager.status = .recording
                case .failure(let error):
                    print("\(error.localizedDescription)")
            }
        }
    }
    
    
    private func stopRecord() {
        screenRecorderManager.stopRecord()
    }
}

extension CVPixelBuffer {
    func toCGImage () -> CGImage? {
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(
            self,
            options: nil,
            imageOut: &image
        )
        return image
    }
}
