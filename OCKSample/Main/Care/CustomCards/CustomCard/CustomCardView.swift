//
//  CustomCardView.swift
//  OCKSample
//
//  Created by Corey Baker on 12/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import SwiftUI
import CareKitUI
import CareKitStore

struct CustomCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: CustomCardViewModel
    @State var completedButtonLabel = "Mark as Completed"
    @State var completedButtonBackground: Color = .secondary

    var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {
                // Example of custom content that looks something like Header.
                 VStack(alignment: .leading, spacing: style.dimension.directionalInsets1.top / 4.0) {
                    Text(viewModel.taskEvents.firstEventTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(viewModel.taskEvents.firstTaskInstructions ?? "")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(Color.primary)

                Divider()

                VStack {

                    HStack {
                        Text("Weight: ")
                            .font(Font.headline)
                        TextField("lbs",
                                  value: $viewModel.weight,
                                  formatter: viewModel.amountFormatter)
                            .keyboardType(.phonePad)
                            .font(Font.title.weight(.bold))
                            .foregroundColor(.accentColor)
                    }

                    HStack(alignment: .center,
                           spacing: style.dimension.directionalInsets2.trailing) {

                        Text("RPE: ")
                            .font(Font.headline)
                        Stepper(value: $viewModel.RPE,
                                in: 1...10,
                                step: 1) {
                            Text("\(viewModel.RPE)")
                                .font(Font.title.weight(.bold))

                        }
                    }
                }
                Button(action: {
                    if completedButtonLabel == "Mark as Completed" {
                        completedButtonLabel = "Completed"
                    } else {
                        completedButtonLabel = "Mark as Completed"
                    }
                    if completedButtonBackground == .secondary {
                        completedButtonBackground = .accentColor
                    } else {
                        completedButtonBackground = .secondary
                    }

                }) {
                    Text(completedButtonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: style.appearance.cornerRadius2,
                                                     style: .continuous)
                            .fill(completedButtonBackground))
                }
            }
            .padding()
        }
        .onReceive(viewModel.$taskEvents) { taskEvents in
            /*
             DO NOT CHANGE THIS. The viewModel needs help
             from view to update "value" since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.checkIfValueShouldUpdate(taskEvents)
        }
    }
}

struct CustomCardView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                               type: .inMemory))))
    }
}
