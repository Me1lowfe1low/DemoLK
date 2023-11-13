import SwiftUI
import LiveKit

struct ParticipantView: View {
    @ObservedObject var participant: Participant
    @EnvironmentObject var appCtx: AppContext
    
    var videoViewMode: VideoView.LayoutMode = .fill
    var onTap: ((_ participant: Participant) -> Void)?
    
    @State private var isRendering: Bool = false
    @State private var dimensions: Dimensions?
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .bottom) {
                // Background color
                Color.customGray1
                    .ignoresSafeArea()
                
                // VideoView for the Participant
                if let publication = participant.mainVideoPublication,
                   !publication.muted,
                   let track = publication.track as? VideoTrack,
                   appCtx.videoViewVisible {
                    ZStack(alignment: .topLeading) {
                        SwiftUIVideoView(
                            track,
                            layoutMode: videoViewMode,
                            mirrorMode: appCtx.videoViewMirrored 
                            ? .mirror
                            : .auto,
                            renderMode: appCtx.preferSampleBufferRendering 
                            ? .sampleBuffer
                            : .auto,
                            debugMode: appCtx.showInformationOverlay,
                            isRendering: $isRendering,
                            dimensions: $dimensions
                        )
                        
                        if !isRendering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .center
                                )
                        }
                    }
                } else if let publication = participant.mainVideoPublication as? RemoteTrackPublication,
                          case .notAllowed = publication.subscriptionState {
                    // Show no permission icon
                    Image(systemName: "exclamationmark.circle").bgView(geometry: geometry)
                } else {
                    // Show no camera icon
                    Image(systemName: "video.slash.fill").bgView(geometry: geometry)
                }
                
                VStack(
                    alignment: .trailing,
                    spacing: 0
                ) {
                    // Show the sub-video view
                    if let subVideoTrack = participant.subVideoTrack {
                        SwiftUIVideoView(
                            subVideoTrack,
                            layoutMode: .fill,
                            mirrorMode: appCtx.videoViewMirrored 
                            ? .mirror
                            : .auto
                        )
                        .background(Color.black)
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: min(
                                geometry.size.width,
                                geometry.size.height
                            ) * 0.3
                        )
                        .cornerRadius(8)
                        .padding()
                    }
                    
                    // Bottom user info bar
                    HStack {
                        Text("\(participant.identity)")
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        if let publication = participant.mainVideoPublication,
                           !publication.muted {
                            // is remote
                            if let remotePub = publication as? RemoteTrackPublication {
                                Menu {
                                    if case .subscribed = remotePub.subscriptionState {
                                        Button {
                                            remotePub.set(subscribed: false)
                                        } label: {
                                            Text("Unsubscribe")
                                        }
                                    } else if case .unsubscribed = remotePub.subscriptionState {
                                        Button {
                                            remotePub.set(subscribed: true)
                                        } label: {
                                            Text("Subscribe")
                                        }
                                    }
                                } label: {
                                    if case .subscribed = remotePub.subscriptionState {
                                        Image(systemName: "video.fill")
                                            .foregroundColor(Color.green)
                                    } else if case .notAllowed = remotePub.subscriptionState {
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundColor(Color.red)
                                    } else {
                                        Image(systemName: "video.slash.fill")
                                    }
                                }
                                .menuStyle(BorderlessButtonMenuStyle())
                                .fixedSize()
                            } else {
                                // local
                                Image(systemName: "video.fill")
                                    .foregroundColor(Color.green)
                            }
                        } else {
                            Image(systemName: "video.slash.fill")
                                .foregroundColor(Color.white)
                        }
                        
                        if let publication = participant.firstAudioPublication,
                           !publication.muted {
                            // is remote
                            if let remotePub = publication as? RemoteTrackPublication {
                                Menu {
                                    if case .subscribed = remotePub.subscriptionState {
                                        Button {
                                            remotePub.set(subscribed: false)
                                        } label: {
                                            Text("Unsubscribe")
                                        }
                                    } else if case .unsubscribed = remotePub.subscriptionState {
                                        Button {
                                            remotePub.set(subscribed: true)
                                        } label: {
                                            Text("Subscribe")
                                        }
                                    }
                                } label: {
                                    if case .subscribed = remotePub.subscriptionState {
                                        Image(systemName: "mic.fill")
                                            .foregroundColor(Color.orange)
                                    } else if case .notAllowed = remotePub.subscriptionState {
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundColor(Color.red)
                                    } else {
                                        Image(systemName: "mic.slash.fill")
                                    }
                                }
                                .menuStyle(BorderlessButtonMenuStyle())
                                .fixedSize()
                            } else {
                                // local
                                Image(systemName: "mic.fill")
                                    .foregroundColor(Color.orange)
                            }
                        } else {
                            Image(systemName: "mic.slash.fill")
                                .foregroundColor(Color.white)
                        }
                        
                        if participant.connectionQuality == .excellent {
                            Image(systemName: "wifi")
                                .foregroundColor(.green)
                        } else if participant.connectionQuality == .good {
                            Image(systemName: "wifi")
                                .foregroundColor(Color.orange)
                        } else if participant.connectionQuality == .poor {
                            Image(systemName: "wifi.exclamationmark")
                                .foregroundColor(Color.red)
                        }
                        
                        if participant.firstTrackEncryptionType == .none {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.green)
                        }
                    }.padding(5)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.black.opacity(0.5))
                }
            }
            .cornerRadius(8)
            // Glow the border when the participant is speaking
            .overlay(
                participant.isSpeaking ?
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        Color.blue,
                        lineWidth: 5.0
                    )
                : nil
            )
        }.gesture(
            TapGesture()
                .onEnded { _ in
                    // Pass the tap event
                    onTap?(participant)
                }
        )
    }
}

extension Participant {
    public var mainVideoPublication: TrackPublication? {
        firstScreenSharePublication ?? firstCameraPublication
    }
    
    public var mainVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack ?? firstCameraVideoTrack
    }
    
    public var subVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack != nil 
        ? firstCameraVideoTrack
        : nil
    }
}
