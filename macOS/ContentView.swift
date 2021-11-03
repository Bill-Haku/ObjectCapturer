//
//  ContentView.swift
//  Shared
//
//  Created by Bill Haku on 2021/10/29.
//  Copyright © 2021 Apple. All rights reserved.
//

import SwiftUI
import RealityKit
//import HelloPhotogrammetry


struct ContentView: View {
    @State var sourcePath: String? = nil
    @State var destinationPath: String? = nil
//    @State var quality: PhotogrammetrySession.Request.Detail = .medium
    @ObservedObject var status = Status()
    @State var progress: Double = 0.0
    @State var isWorking = false
    @State var isSuccess = false
    var qualityTypes = ["Preview", "Reduced", "Medium", "Full", "Raw"]
    @State var selectedQuality = 2
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: sourcePath == nil ? "folder.fill.badge.plus" : "folder.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    Text(sourcePath ?? "Choose source path")
                    Button("select path") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        if panel.runModal() == .OK {
                            self.sourcePath = panel.url?.absoluteString
                            sourcePath = sourcePath!.replacingOccurrences(of: "file://", with: "")
                        }
                    }
                }
                .padding()
                .frame(width: 250)
                VStack {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    Text(destinationPath ?? "Choose destination path")
                    Button("select path") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        if panel.runModal() == .OK {
                            self.destinationPath = panel.url?.absoluteString
                            destinationPath = destinationPath!.replacingOccurrences(of: "file://", with: "")
                            destinationPath! += "output.usdz"
                        }
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
            .frame(width: 300)
//            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Button(isWorking ? "Working" : "Start") {
                if sourcePath != nil && destinationPath != nil {
                    DispatchQueue.global().async {
                        switch selectedQuality {
                        case 1:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .preview, progress: $progress, isSuccess: $isSuccess, isWorking: $isWorking)
                            core.run()
                        case 2:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .reduced, progress: $progress, isSuccess: $isSuccess, isWorking: $isWorking)
                            core.run()
                        case 3:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .medium, progress: $progress, isSuccess: $isSuccess, isWorking: $isWorking)
                            core.run()
                        case 4:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .full, progress: $progress, isSuccess: $isSuccess, isWorking: $isWorking)
                            core.run()
                        case 5:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: .raw, progress: $progress, isSuccess: $isSuccess, isWorking: $isWorking)
                            core.run()
                        default:
                            let core = HelloPhotogrammetry(input: sourcePath!, outputStr: destinationPath!, outputDetail: nil, progress: $progress, isSuccess: $isSuccess, isWorking: $isWorking)
                            core.run()
                        }
                        
                        
                        isWorking = true
                    }
                }
            }
            .disabled(isWorking)
            if isWorking {
                ProgressView("Working...", value: progress, total: 1)
                    .padding()
            }
            if isSuccess {
                Text("Success!")
                    .font(.title)
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
