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

    var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {
                /*
                // Example of custom content that looks something like Header.
                 // xTODO: Remove this if you don't use it.
                 VStack(alignment: .leading, spacing: style.dimension.directionalInsets1.top / 4.0) {
                    Text(viewModel.taskEvents.firstEventTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(viewModel.taskEvents.firstEventDetail ?? "")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(Color.primary)
                */
                // Can look through HeaderView for creating custom
                HeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                           detail: Text(viewModel.taskEvents.firstEventDetail ?? ""))
                Divider()
                HStack(alignment: .center,
                       spacing: style.dimension.directionalInsets2.trailing) {

                    /*
                     // Example of custom content.
                     xTODO: Remove all that you are not using.
                     */
                    Button(action: {
                        Task {
                            await viewModel.action(viewModel.value)
                        }
                    }) {
                        CircularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                            Image(systemName: "checkmark") // Can place any view type here
                                .resizable()
                                .padding()
                                .frame(width: 50, height: 50) // Change size to make larger/smaller
                        }
                    }
                    Spacer()

                    Text("Input: ")
                        .font(Font.headline)
                    TextField("0.0",
                              value: $viewModel.value,
                              formatter: viewModel.amountFormatter)
                        .keyboardType(.decimalPad)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)

                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.action(viewModel.value)
                        }
                    }) {
                        RectangularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                            Image(systemName: "checkmark") // Can place any view type here
                                .resizable()
                                .padding()
                                .frame(width: 50, height: 50) // Change size to make larger/smaller
                        }
                    }

                    Text(viewModel.valueForButton)
                        .multilineTextAlignment(.trailing)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)
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
