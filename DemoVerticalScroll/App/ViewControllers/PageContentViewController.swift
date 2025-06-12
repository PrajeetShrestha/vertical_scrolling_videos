//
//  HorizontalPageContainerViewController.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//
import UIKit
import AVKit
import Combine

class PageContentViewController: UIViewController {
    internal let verticalIndex: Int
    private let feedDetail: UserFeedDetail
    private let profileNameLabel = UILabel()
    private var playerController = AVPlayerViewController()
    
    private var cancellables = Set<AnyCancellable>()
    private var asset: AVAsset? = nil
    private var player: AVPlayer? = nil
    private var playerItem: AVPlayerItem? = nil
    private var looper: AVPlayerLooper? = nil
    private var videoModel: Video {
        return feedDetail.videos[0]
    }
    
    private var pageTracker = PageTracker.shared
    
    
    init(verticalIndex: Int, feedDetail: UserFeedDetail) {
        self.verticalIndex = verticalIndex
        self.feedDetail = feedDetail
        super.init(nibName: nil, bundle: nil)
        self.title = "Page \(verticalIndex + 1)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageObserver()
        
    }
    
    func setupPageObserver() {
        pageTracker.$currentPage
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(30), scheduler: DispatchQueue.main)
            .sink { [weak self] page in
                guard let self = self else { return }
                
                // Only log if this ContentViewController is the active page
                if page.verticalIndex == self.verticalIndex
                {
                    playerController.player?.play()
                } else {
                    playerController.player?.pause()
                }
            }
            .store(in: &cancellables)
    }
    private func setupUI() {
        view.backgroundColor = .white
        addChild(playerController)
        view.addSubview(playerController.view)
        
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        playerController.view.pinToEdges(of: view)
        playerController.didMove(toParent: self)
        playerController.showsPlaybackControls = false
        playerController.allowsVideoFrameAnalysis = false
        
        profileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileNameLabel.text = feedDetail.userProfileDetails.name
        profileNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        profileNameLabel.textColor = .black
        profileNameLabel.textAlignment = .center
        profileNameLabel.numberOfLines = 1
        
        view.addSubview(profileNameLabel)
        
        NSLayoutConstraint.activate([
            profileNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        setupPlayer()
    }
    
    private func setupPlayer() {
        if let _ = self.asset {
            return
        }
        guard let mediaURL = URL(string: videoModel.mediaUrl) else { return }
        Task {
            let asset = await AssetPool.shared.getCachedAsset(for: videoModel.contentId, remoteURL: mediaURL)
            self.asset = asset
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.preferredForwardBufferDuration = 2.0
            self.playerItem = playerItem
            let player = AVQueuePlayer(playerItem: playerItem)
            self.player = player
            playerController.player = player
            self.looper = AVPlayerLooper(player: player, templateItem: playerItem)
            
        }
    }
}
