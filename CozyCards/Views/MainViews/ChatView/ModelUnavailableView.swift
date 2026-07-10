import SwiftUI



/// What the chat shows when the on-device model cannot run.
///
/// There is no Private Cloud Compute fallback, so this is not a spinner and not
/// a transient error - for a real share of devices it is the only state chat
/// will ever have. The three reasons want three different answers: an ineligible
/// device can do nothing, a disabled Apple Intelligence is one tap away in
/// Settings, and a downloading model just needs a minute.
struct ModelUnavailableView: View {


    let availability: ModelAvailability


    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        }
        .background(.background)
    }


    private var title: String {
        switch availability {
        case .modelNotReady: "Getting ready"
        case .appleIntelligenceNotEnabled: "Apple Intelligence is off"
        case .deviceNotEligible, .unavailable, .available: "Chat is unavailable"
        }
    }


    private var icon: String {
        switch availability {
        case .modelNotReady: "arrow.down.circle"
        case .appleIntelligenceNotEnabled: "gearshape"
        case .deviceNotEligible, .unavailable, .available: "exclamationmark.triangle"
        }
    }


    private var message: String {
        switch availability {
        case .modelNotReady:
            "The language model is still downloading. This usually takes a few minutes."
        case .appleIntelligenceNotEnabled:
            "Turn on Apple Intelligence in Settings to ask about words. Your library still works."
        case .deviceNotEligible:
            "This device can't run the on-device language model. Your library still works."
        case .unavailable, .available:
            "The language model isn't available right now. Your library still works."
        }
    }


}



#Preview("Not eligible") {
    ModelUnavailableView(availability: .deviceNotEligible)
}


#Preview("Downloading") {
    ModelUnavailableView(availability: .modelNotReady)
}
