import SwiftUI
import LiveKit
import BroadcastExtension

struct ParticipantView: View {
    @ObservedObject var participant: Participant
    @EnvironmentObject var applicationContext: AppContext
    
    var videoViewMode: VideoView.LayoutMode = .fill
    var onTap: ((_ participant: Participant) -> Void)?
    
    @State private var isRendering: Bool = false
    @State private var dimensions: Dimensions?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color(.lightGray)
                    .ignoresSafeArea()
                
                // VideoView for the Participant
                if let publication = participant.mainVideoPublication,
                   !publication.muted,
                   var track = publication.track as? VideoTrack,
                   applicationContext.videoViewVisible {
                    ZStack(alignment: .topLeading) {
                        if participant.firstScreenShareVideoTrack != nil,
                        let tempTrack = participant.firstScreenShareVideoTrack as? VideoTrack{
                            
                            SwiftUIVideoView(
                                tempTrack,
                                layoutMode: videoViewMode,
                                mirrorMode: applicationContext.videoViewMirrored
                                ? .mirror
                                : .auto,
                                renderMode: applicationContext.preferSampleBufferRendering
                                ? .sampleBuffer
                                : .auto,
                                debugMode: applicationContext.showInformationOverlay,
                                isRendering: $isRendering,
                                dimensions: .constant(Dimensions(width: 300, height: 300))
                            )
                        } else {
                            SwiftUIVideoView(
                                track,
                                layoutMode: videoViewMode,
                                mirrorMode: applicationContext.videoViewMirrored
                                ? .mirror
                                : .auto,
                                renderMode: applicationContext.preferSampleBufferRendering
                                ? .sampleBuffer
                                : .auto,
                                debugMode: applicationContext.showInformationOverlay,
                                isRendering: $isRendering,
                                dimensions: $dimensions
                            )
                        }
                        
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
                    Image(systemName: "exclamationmark.circle").backgroundIcon(geometry: geometry)
                } else {
                    Image(systemName: "video.slash.fill").backgroundIcon(geometry: geometry)
                }
                
                VStack(
                    alignment: .trailing,
                    spacing: verticalSpacing
                ) {
                    // Show the sub-video view
                    if let subVideoTrack = participant.subVideoTrack {
                        SwiftUIVideoView(
                            subVideoTrack,
                            layoutMode: .fill,
                            mirrorMode: applicationContext.videoViewMirrored 
                            ? .mirror
                            : .auto
                        )
                        .background(Color.black)
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: min(
                                geometry.size.width,
                                geometry.size.height
                            ) * imageSizingCoefficient
                        )
                        .cornerRadius(subVideoTrackRadius)
                        .padding()
                    }
                    
                    // Bottom user info bar
                    HStack {
                        Text("\(participant.identity)")
                            .lineLimit(infoBarLineLimit)
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
                    }
                    .padding(infoBarPadding)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity
                    )
                    .background(infoBarBackgroundColor.opacity(infoBarBackgroundColorOpacity))
                }
            }
            .cornerRadius(participantViewRadius)
            .overlay(
                participant.isSpeaking ?
                RoundedRectangle(cornerRadius: overlayCornerRadius)
                    .stroke(
                        overlayBorderColor,
                        lineWidth: overlayBorderWidth
                    )
                : nil
            )
        }.gesture(
            TapGesture()
                .onEnded { _ in
                    onTap?(participant)
                }
        )
    }
}

private let verticalSpacing: CGFloat = 0.0
private let overlayCornerRadius: CGFloat = 4.0
private let overlayBorderColor: Color = .blue
private let overlayBorderWidth: CGFloat = 4.0

private let imageSizingCoefficient: CGFloat = 0.3
private let subVideoTrackRadius: CGFloat = 8.0
private let participantViewRadius: CGFloat = 8.0

private let infoBarLineLimit: Int = 1
private let infoBarPadding:  CGFloat = 5.0
private let infoBarBackgroundColor: Color = .black
private let infoBarBackgroundColorOpacity: CGFloat = 0.5

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
