import SwiftUI

public struct AsyncButton<Label: View>: View {
    public enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }

    var action: () async -> Void
    var actionOptions = Set(ActionOption.allCases)
    @ViewBuilder var label: () -> Label
    
    public init(
        action: @escaping () async -> Void,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        label: @escaping () -> Label
    ) {
        self.action = action
        self.actionOptions = actionOptions
        self.label = label
    }

    @State private var isDisabled = false
    @State private var showProgressView = false

    public var body: some View {
        SwiftUI.Button(
            action: {
                if actionOptions.contains(.disableButton) {
                    isDisabled = true
                }

                if actionOptions.contains(.showProgressView) {
                    showProgressView = true
                }

                Task {
                    await action()
                    isDisabled = false
                    showProgressView = false
                }
            },
            label: {
                ZStack {
                    label().opacity(showProgressView ? 0 : 1)

                    if showProgressView {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
        )
        .disabled(isDisabled)
    }
}
