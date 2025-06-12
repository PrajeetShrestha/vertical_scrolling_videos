//
//  VideoCacheManager.swift
//  Entervu
//
//  Created by Prajeet Shrestha on 27/03/2025.
//
import Foundation
import UIKit
import OSLog

class VideoCacheManager: NSObject, URLSessionDownloadDelegate {
    static let shared = VideoCacheManager()

    private let cacheDirectory: URL
    private let logger = Logger(subsystem: "com.entervu.videoplayer", category: "cache")
    private var activeDownloads: [Int: URLSessionDownloadTask] = [:]
    private var downloadSession: URLSession! = nil
    
    static let videoCachedNotification = Notification.Name("VideoCachedNotification")
    
    private override init() {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cachesDirectory.appendingPathComponent("VideoCaches")
        
        // Call super.init() before using self
        super.init()
        
        // Now safe to use self
        let config = URLSessionConfiguration.background(withIdentifier: "com.entervu.videocache")
        config.sessionSendsLaunchEvents = true
        config.httpMaximumConnectionsPerHost = 3 // Limit to 3 concurrent downloads
        
        // Initialize URLSession with self as delegate
        self.downloadSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        do {
            if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
                try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                logger.info("Created VideoCaches directory at \(self.cacheDirectory.path)")
            }
        } catch {
            logger.error("Failed to create VideoCaches directory: \(error.localizedDescription)")
        }
    }
    
    func cachedFileURL(forContentID contentID: Int) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent("\(contentID).mp4")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            logger.debug("Found cached video for contentID \(contentID) at \(fileURL.path)")
            return fileURL
        }
        logger.debug("No cached video found for contentID \(contentID)")
        return nil
    }
    
    func cacheVideoInBackground(from remoteURL: URL, contentID: Int) {
        let destinationURL = cacheDirectory.appendingPathComponent("\(contentID).mp4")
        
        // Skip if already cached or downloading
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            logger.info("Video already cached for contentID \(contentID)")
            notifyVideoCached(contentID: contentID, fileURL: destinationURL)
            return
        }
        
        if activeDownloads[contentID] != nil {
            logger.debug("Download already in progress for contentID \(contentID)")
            return
        }
        
        logger.info("Starting background download for contentID \(contentID) from \(remoteURL.absoluteString)")
        let task = downloadSession.downloadTask(with: remoteURL)
        activeDownloads[contentID] = task
        task.resume()
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let contentID = activeDownloads.first(where: { $0.value == downloadTask })?.key else {
            logger.error("No matching contentID for completed download task")
            return
        }
        
        defer { activeDownloads.removeValue(forKey: contentID) }
        
        let destinationURL = cacheDirectory.appendingPathComponent("\(contentID).mp4")
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            logger.info("Cached video for contentID \(contentID) at \(destinationURL.path)")
            notifyVideoCached(contentID: contentID, fileURL: destinationURL)
        } catch {
            logger.error("Failed to move video file for contentID \(contentID): \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let contentID = activeDownloads.first(where: { $0.value == task })?.key else { return }
        
        defer { activeDownloads.removeValue(forKey: contentID) }
        
        if let error = error {
            logger.error("Failed to download video for contentID \(contentID): \(error.localizedDescription)")
        }
    }
    
    // Notify observers when a video is cached
    private func notifyVideoCached(contentID: Int, fileURL: URL) {
        NotificationCenter.default.post(name: VideoCacheManager.videoCachedNotification,
                                        object: nil,
                                        userInfo: ["contentID": contentID, "fileURL": fileURL])
    }
    
    func clearCache() throws {
        try FileManager.default.removeItem(at: cacheDirectory)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        logger.info("Cleared video cache directory")
    }
}
