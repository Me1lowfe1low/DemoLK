import SwiftUI
import AVFoundation
import CoreMedia

struct ScreenShareView: View {
    @Binding var buffer: CMSampleBuffer?
    
    var body: some View {
        VStack {
            if let buffer = buffer {
                VideoTestView(sampleBuffer: $buffer)
                    .onAppear {
                        print("🫎 appeared")
                    }
//                    .frame(
//                        width: 300, 
//                        height: 300
//                    )
            }
        }
    }
}

struct VideoTestView: UIViewRepresentable {
    @Binding var sampleBuffer: CMSampleBuffer?
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        if let sampleBuffer = sampleBuffer {
            if let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.frame = view.bounds
                view.addSubview(imageView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let sampleBuffer = sampleBuffer else { return }
        let displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.frame = uiView.bounds
        displayLayer.videoGravity = .resizeAspect
        displayLayer.enqueue(sampleBuffer)
        uiView.layer.addSublayer(displayLayer)
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
