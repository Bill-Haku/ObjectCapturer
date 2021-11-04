//
//  ContentView.swift
//  Shared
//
//  Created by Bill Haku on 2021/10/29.
//  Copyright © 2021 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State var sourcePath: String? = nil
    @State var destinationPath: String? = nil
    @State var progress: Double = 0.0
    @State var myStatus: CurrentStatus = .isWaiting
    var qualityTypes = ["Preview", "Reduced", "Medium", "Full", "Raw"]
    @State var selectedQuality = 2
    @State var outputName = ""
    @State var localError: ErrorTypes = .noError
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: sourcePath == nil ? "folder.fill.badge.plus" : "folder.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding()
                    if sourcePath == nil {
                        Text("Choose source path")
                    } else {
                        Text(sourcePath!)
                    }
                    Button("Select path") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        if panel.runModal() == .OK {
                            self.sourcePath = panel.url?.absoluteString
                            sourcePath = sourcePath!.replacingOccurrences(of: "file://", with: "")
                        }
                    }
                    .disabled(myStatus == .isWorking)
                }
                .padding()
                .frame(width: 250)
                VStack {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding()
                    if destinationPath == nil {
                        Text("Choose destination path")
                    } else {
                        Text(destinationPath!)
                    }
                    HStack {
                        Button("Select path") {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseFiles = false
                            panel.canChooseDirectories = true
                            if panel.runModal() == .OK {
                                self.destinationPath = panel.url?.absoluteString
                                destinationPath = destinationPath!.replacingOccurrences(of: "file://", with: "")
                            }
                        }
                        .disabled(myStatus == .isWorking)
                        TextField("Output file name", text: $outputName)
                        .disabled(myStatus == .isWorking)
                    }
                }
                .frame(width: 250)
                .padding()
            }
            Picker("Output Quality", selection: $selectedQuality) {
                ForEach(0..<qualityTypes.count) { i in
                    Text(qualityTypes[i])
                }
            }
            .disabled(myStatus == .isWorking)
            .frame(width: 300)
            .padding()
            Button(myStatus == .isWorking ? "Working" : "Start") {
                if sourcePath == nil {
                    showAlert.toggle()
                    localError = .srcNil
                } else if destinationPath == nil {
                    showAlert.toggle()
                    localError = .desNil
                } else {
                    if outputName != "" {
                        destinationPath! += "\(outputName).usdz"
                    } else {
                        destinationPath! += "output.usdz"
                    }
                    DispatchQueue.global().async {
                        switch selectedQuality {
                        case 1:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .preview, progress: $progress, myStatus: $myStatus)
                            core.run()
                        case 2:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .reduced, progress: $progress, myStatus: $myStatus)
                            core.run()
                        case 3:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .medium, progress: $progress, myStatus: $myStatus)
                            core.run()
                        case 4:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .full, progress: $progress, myStatus: $myStatus)
                            core.run()
                        case 5:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .raw, progress: $progress, myStatus: $myStatus)
                            core.run()
                        default:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: nil, progress: $progress, myStatus: $myStatus)
                            core.run()
                        }
                        myStatus = .isWorking
                    }
                }
            }
            .padding()
            .disabled(myStatus == .isWorking)
            .alert(isPresented: $showAlert) {
                switch localError {
                case .noError:
                    return Alert(title: Text("Undefined error"), dismissButton: .default(Text("OK")))
                case .desNil:
                    return Alert(title: Text("Output path is not set"), dismissButton: .default(Text("OK")))
                case .srcNil:
                    return Alert(title: Text("Source path is not set"), dismissButton: .default(Text("OK")))
                }
            }
            if myStatus == .isWorking {
                ProgressView("Working...", value: progress, total: 1)
                    .padding()
            }
            if myStatus == .isSuccess {
                Text("Success!")
                    .font(.title3)
                    .padding()
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
