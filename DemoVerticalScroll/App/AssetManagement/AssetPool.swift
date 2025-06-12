//
//  AssetPool.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//

import AVFoundation
import OSLog

private let logger = Logger(subsystem: "com.entervu.videoplayer", category: "assetpool")

actor AssetPool { // Changed to actor
    static let shared = AssetPool()
    private var cachedContentIds: Set<NSNumber> = []
    let mediaCache = NSCache<NSNumber, AVAsset>()
    private let cacheManager = VideoCacheManager.shared // Assume cacheManager is safe
    private let preloadRange = 15
    
    private init() {}
    
    func getCachedAsset(for contentId: Int, remoteURL: URL) -> AVAsset {
        let cacheKey = NSNumber(value: contentId)
        if let asset = mediaCache.object(forKey: cacheKey) {
            return asset
        } else {
            let urlAsset = AVURLAsset(url: remoteURL)
            return urlAsset
        }
    }
    
    func updateAssetPool(userFeedDetails: [UserFeedDetail], currentIndex: Int, preloadRange: Int) {
        // Calculate start and end indices for preloading
        let startIndex = max(0, currentIndex - preloadRange)
        let endIndex = min(userFeedDetails.count - 1, currentIndex + preloadRange)
        if endIndex < 1 { return }
        // Collect contentIds within the preload range
        var contentIdsInRange: Set<Int> = []

        
        // Remove assets outside the preload range
        removeAssetsOutsideRange(keepingContentIds: contentIdsInRange)
    }
    
    private func preloadMedia(mediaFullUrl: String, contentId: Int) {
        // Check if the asset is already cached
        let cacheKey = NSNumber(value: contentId)
        if mediaCache.object(forKey: cacheKey) != nil {
            //print("Asset already cached for contentId: \(contentId)")
            return
        }
        
        // Validate URL
        guard let url = URL(string: mediaFullUrl) else {
            print("Invalid URL: \(mediaFullUrl) for contentId: \(contentId)")
            return
        }
        
        let urlToPreload: URL
        let newAsset: AVAsset
        if let cachedURL = cacheManager.cachedFileURL(forContentID: contentId) {
            // Local file: No need to preload, just create the asset
            urlToPreload = cachedURL
            newAsset = AVAsset(url: urlToPreload)
            self.cachedContentIds.insert(cacheKey)
            mediaCache.setObject(newAsset, forKey: cacheKey)
            logger.debug("Using cached asset for contentID \(contentId) without preloading")
        } else {
            // Remote file: Preload and cache
            urlToPreload = url
            logger.debug("Will preload remote asset for contentID \(contentId)")
            cacheManager.cacheVideoInBackground(from: url, contentID: contentId)
            newAsset = AVAsset(url: urlToPreload)
            Task {
                try await newAsset.load(.duration, .isPlayable)
            }//preloader.preloadAsset(for: urlToPreload, contentID: String(contentId))
            self.cachedContentIds.insert(cacheKey)
            mediaCache.setObject(newAsset, forKey: cacheKey)
        }
    }
    
    private func removeAssetsOutsideRange(keepingContentIds: Set<Int>) {
        // Convert keepingContentIds to Set<NSNumber> for comparison
        let keepingKeys = Set(keepingContentIds.map { NSNumber(value: $0) })
        
        // Remove assets whose contentIds are not in keepingKeys
        for cacheKey in cachedContentIds {
            if !keepingKeys.contains(cacheKey) {
                mediaCache.removeObject(forKey: cacheKey)
                cachedContentIds.remove(cacheKey)
                print("Removed asset for contentId: \(cacheKey.intValue) from cache")
            }
        }
    }
    
}
