import SwiftUI

struct ConnectionTextField: View {
    enum `Type` {
        case defaultValue
        case URL
        case ascii
    }
    
    let title: String
    @Binding var text: String
    var type: Type = .defaultValue
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10.0
        ) {
            Text(title)
                .fontWeight(.bold)
            
            TextField("", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(type.toiOSType())
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: overlayCornerRadius)
                        .strokeBorder(
                            overlayBorderColor.opacity(overlayBorderColorOpacity),
                            style: StrokeStyle(lineWidth: overlayBorderWidth)
                        )
                )
        }
        .frame(maxWidth: .infinity)
    }
}

private let overlayCornerRadius: CGFloat = 4.0
private let overlayBorderColor: Color = .white
private let overlayBorderColorOpacity: CGFloat = 0.7
private let overlayBorderWidth: CGFloat = 1.0

extension ConnectionTextField.`Type` {
    func toiOSType() -> UIKeyboardType {
        switch self {
            case .defaultValue: return .default
            case .URL: return .URL
            case .ascii: return .asciiCapable
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.gray
        .opacity(0.7)
        
        ConnectionTextField(
            title: "Temporary field",
            text: .constant("Temporary text"),
            type: .defaultValue
        )
        .padding()
    }
}
#endif
