//
//  Coreprocess.swift
//  HelloPhotogrammetry
//
//  Created by Bill Haku on 2021/10/29.
//  Copyright © 2021 Apple. All rights reserved.
//
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
RealityKit Object Creation command line tools.
*/

import ArgumentParser  // Available from Apple: https://github.com/apple/swift-argument-parser
import Foundation
import os
import RealityKit
import SwiftUI

let logger = Logger(subsystem: "com.apple.sample.photogrammetry",
                            category: "HelloPhotogrammetry")

/// Implements the main command structure, defines the command-line arguments,
/// and specifies the main run loop.
struct HelloPhotogrammetry {
    
    var input: String
    var outputStr: String
    var outputDetail: Request.Detail? = nil
    @Binding var progress: Double
    @Binding var myStatus: CurrentStatus
    @Binding var errorInfo: String
    @Binding var showAlert: Bool
    
    typealias Configuration = PhotogrammetrySession.Configuration
    typealias Request = PhotogrammetrySession.Request
    
//    public static let configuration = CommandConfiguration(
//        abstract: "Reconstructs 3D USDZ model from a folder of images.")
//    var inputFolder: String = ""
//    var outputFilename: String = ""
//    var detail: Request.Detail?
    var sampleOrdering: Configuration.SampleOrdering?
    var featureSensitivity: Configuration.FeatureSensitivity?
    
    /// The main run loop entered at the end of the file.
    func run() {
        let inputFolderUrl = URL(fileURLWithPath: input, isDirectory: true)
        let configuration = makeConfigurationFromArguments()
        logger.log("Using configuration: \(String(describing: configuration))")
        
        // Try to create the session, or else exit.
        var maybeSession: PhotogrammetrySession? = nil
        do {
            maybeSession = try PhotogrammetrySession(input: inputFolderUrl,
                                                     configuration: configuration)
            logger.log("Successfully created session.")
        } catch {
            logger.error("Error creating session: \(String(describing: error))")
            showAlert = true
            myStatus = .isFail
            errorInfo = "Error creating session: \(String(describing: error))"
            return
        }
        guard let session = maybeSession else {
            myStatus = .isFail
            showAlert = true
            errorInfo = "error: create session fail"
            return
        }
        
        let waiter = Task {
            do {
                for try await output in session.outputs {
                    switch output {
                    case .processingComplete:
                        logger.log("Processing is complete!")
                    case .requestError(let request, let error):
                        logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                        myStatus = .isFail
                        showAlert.toggle()
                        errorInfo = "error: \(String(describing: error))"
                    case .requestComplete(let request, let result):
                        HelloPhotogrammetry.handleRequestComplete(request: request, result: result)
                        myStatus = .isSuccess
                        showAlert = true
                    case .requestProgress(let request, let fractionComplete):
                        HelloPhotogrammetry.handleRequestProgress(request: request, fractionComplete: fractionComplete)
                        progress = fractionComplete
                    case .inputComplete:  // data ingestion only!
                        logger.log("Data ingestion is complete.  Beginning processing...")
                    case .invalidSample(let id, let reason):
                        logger.warning("Invalid Sample! id=\(id)  reason=\"\(reason)\"")
                    case .skippedSample(let id):
                        logger.warning("Sample id=\(id) was skipped by processing.")
                    case .automaticDownsampling:
                        logger.warning("Automatic downsampling was applied!")
                    case .processingCancelled:
                        logger.warning("Processing was cancelled.")
                    @unknown default:
                        logger.error("Output: unhandled message: \(output.localizedDescription)")
                        myStatus = .isFail
                        showAlert = true
                        errorInfo = "unhandled message: \(output.localizedDescription)"
                    }
                }
            } catch {
                logger.error("Output: ERROR = \(String(describing: error))")
                myStatus = .isFail
                showAlert = true
                errorInfo = "ERROR = \(String(describing: error))"
            }
        }
        
        // The compiler may deinitialize these objects since they may appear to be
        // unused. This keeps them from being deallocated until they exit.
        withExtendedLifetime((session, waiter)) {
            // Run the main process call on the request, then enter the main run
            // loop until you get the published completion event or error.
            do {
                let request = makeRequestFromArguments()
                logger.log("Using request: \(String(describing: request))")
                try session.process(requests: [ request ])
                // Enter the infinite loop dispatcher used to process asynchronous
                // blocks on the main queue. You explicitly exit above to stop the loop.
                RunLoop.main.run()
            } catch {
                logger.critical("Process got error: \(String(describing: error))")
                myStatus = .isFail
                showAlert = true
                errorInfo = "Process got error: \(String(describing: error))"
            }
        }
    }

    /// Creates the session configuration by overriding any defaults with arguments specified.
    private func makeConfigurationFromArguments() -> PhotogrammetrySession.Configuration {
        var configuration = PhotogrammetrySession.Configuration()
        sampleOrdering.map { configuration.sampleOrdering = $0 }
        featureSensitivity.map { configuration.featureSensitivity = $0 }
        return configuration
    }

    /// Creates a request to use based on the command-line arguments.
    private func makeRequestFromArguments() -> PhotogrammetrySession.Request {
        let outputUrl = URL(fileURLWithPath: outputStr)
        if let detailSetting = outputDetail {
            return PhotogrammetrySession.Request.modelFile(url: outputUrl, detail: detailSetting)
        } else {
            return PhotogrammetrySession.Request.modelFile(url: outputUrl)
        }
    }
    
    /// Called when the the session sends a request completed message.
    private static func handleRequestComplete(request: PhotogrammetrySession.Request,
                                              result: PhotogrammetrySession.Result) {
        logger.log("Request complete: \(String(describing: request)) with result...")
        switch result {
            case .modelFile(let url):
                logger.log("\tmodelFile available at url=\(url)")
            default:
                logger.warning("\tUnexpected result: \(String(describing: result))")
        }
    }
    
    /// Called when the sessions sends a progress update message.
    private static func handleRequestProgress(request: PhotogrammetrySession.Request,
                                              fractionComplete: Double) {
        logger.log("Progress(request = \(String(describing: request)) = \(fractionComplete)")
    }

}

// MARK: - Helper Functions / Extensions

private func handleRequestProgress(request: PhotogrammetrySession.Request,
                                   fractionComplete: Double) {
    print("Progress(request = \(String(describing: request)) = \(fractionComplete)")
}

/// Error thrown when an illegal option is specified.
private enum IllegalOption: Swift.Error {
    case invalidDetail(String)
    case invalidSampleOverlap(String)
    case invalidSampleOrdering(String)
    case invalidFeatureSensitivity(String)
}

/// Extension to add a throwing initializer used as an option transform to verify the user-supplied arguments.
@available(macOS 12.0, *)
extension PhotogrammetrySession.Request.Detail {
    init(_ detail: String) throws {
        switch detail {
            case "preview": self = .preview
            case "reduced": self = .reduced
            case "medium": self = .medium
            case "full": self = .full
            case "raw": self = .raw
            default: throw IllegalOption.invalidDetail(detail)
        }
    }
}

@available(macOS 12.0, *)
extension PhotogrammetrySession.Configuration.SampleOrdering {
    init(sampleOrdering: String) throws {
        if sampleOrdering == "unordered" {
            self = .unordered
        } else if sampleOrdering == "sequential" {
            self = .sequential
        } else {
            throw IllegalOption.invalidSampleOrdering(sampleOrdering)
        }
    }
    
}

@available(macOS 12.0, *)
extension PhotogrammetrySession.Configuration.FeatureSensitivity {
    init(featureSensitivity: String) throws {
        if featureSensitivity == "normal" {
            self = .normal
        } else if featureSensitivity == "high" {
            self = .high
        } else {
            throw IllegalOption.invalidFeatureSensitivity(featureSensitivity)
        }
    }
}

enum QualityType: String, Equatable, CaseIterable {
    case preview = "Preview"
    case reduced = "Reduced"
    case medium = "Medium"
    case full = "Full"
    case raw = "Raw"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum CurrentStatus {
    case isWorking
    case isSuccess
    case isFail
    case isWaiting
}

enum ErrorTypes {
    case noError
    case srcNil
    case desNil
    case coreFail
}
