//
//  ExploreSectionViewController.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//

import UIKit


class ExploreSectionViewController: UIViewController {
    private var verticalPageViewController: UIPageViewController!
    private var userFeedArray = [UserFeedDetail]()
    private let pageTracker = PageTracker.shared
    private weak var currentPageVC: PageContentViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTracker.reset()
        loadData()
        setupCoreUI()
    }
    
    private func loadData() {
        if let response = loadFilteredResponse() {
            self.userFeedArray = response.data.userFeedDetails
            AssetPool.shared.updateAssetPool(
                userFeedDetails: userFeedArray,
                currentIndex: 10,
                preloadRange: 15
            )
        }
    }
    
    private func setupCoreUI() {
        verticalPageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: nil
        )
        
        verticalPageViewController.delegate = self
        verticalPageViewController.dataSource = self
        addChild(verticalPageViewController)
        view.addSubview(verticalPageViewController.view)
        verticalPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        verticalPageViewController.view.pinToEdges(of: view)
        verticalPageViewController.didMove(toParent: self)
        // Set initial page
        let firstPage = pageAtIndex(index: 0)
        currentPageVC = firstPage
        verticalPageViewController.setViewControllers(
            [firstPage],
            direction: .forward,
            animated: false,
            completion: nil
        )
        pageTracker.updatePage(verticalIndex: 0, horizontalIndex: 0)
    }
    
    private func pageAtIndex(index: Int) -> PageContentViewController {
        // Ensure index is valid
        let safeIndex = min(max(index, 0), userFeedArray.count - 1)
        return PageContentViewController(
            verticalIndex: safeIndex,
            feedDetail: userFeedArray[safeIndex]
        )
    }
}

// MARK: - UIPageViewControllerDelegate
extension ExploreSectionViewController: UIPageViewControllerDelegate, UIScrollViewDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed,
           let currentPage = pageViewController.viewControllers?.first as? PageContentViewController {
            let verticalIndex = currentPage.verticalIndex
            pageTracker.updatePage(verticalIndex: verticalIndex,
                                   horizontalIndex: 0)
            currentPageVC = currentPage
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(
            name: .scrollViewDidScroll,
            object: nil
        )
    }
}

// MARK: - UIPageViewControllerDataSource
extension ExploreSectionViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = viewController as? PageContentViewController,
              currentPage.verticalIndex > 0 else {
            return nil
        }
        return pageAtIndex(index: currentPage.verticalIndex - 1)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = viewController as? PageContentViewController else {
            return nil
        }
        
        let nextIndex = currentPage.verticalIndex + 1
        
        guard nextIndex < userFeedArray.count else {
            return nil
        }
        
        return pageAtIndex(index: nextIndex)
    }
}
