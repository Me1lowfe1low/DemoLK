import SwiftUI

struct LKTextField: View {
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
                    RoundedRectangle(cornerRadius: 4.0)
                        .strokeBorder(
                            Color.white.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.0)
                        )
                )
        }.frame(maxWidth: .infinity)
    }
}

extension LKTextField.`Type` {
    func toiOSType() -> UIKeyboardType {
        switch self {
            case .defaultValue: return .default
            case .URL: return .URL
            case .ascii: return .asciiCapable
        }
    }
}
