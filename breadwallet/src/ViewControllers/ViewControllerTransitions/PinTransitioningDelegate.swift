//
//  PinTransitioningDelegate.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-05-05.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

private let duration: TimeInterval = 0.4

class PinTransitioningDelegate : NSObject , UIViewControllerTransitioningDelegate {

    var shouldShowMaskView = true

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentPinAnimator(shouldShowMaskView: shouldShowMaskView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissPinAnimator()
    }
}

class PresentPinAnimator : NSObject, UIViewControllerAnimatedTransitioning {

    init(shouldShowMaskView: Bool) {
        self.shouldShowMaskView = shouldShowMaskView
    }

    private let shouldShowMaskView: Bool

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let container = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let toVc = transitionContext.viewController(forKey: .to) as? ContentBoxPresenter else { return }

        /*
        let blurView = toVc.blurView
        blurView.frame = container.frame
        blurView.effect = nil
        container.addSubview(blurView)
         */
        
        toVc.background.frame = UIScreen.main.bounds
        toVc.background.alpha = 0
        container.addSubview(toVc.background)
        
        let fromFrame = container.frame
        let maskView = UIView(frame: CGRect(x: 0, y: fromFrame.height, width: fromFrame.width, height: 80.0))
        maskView.backgroundColor = C.Colors.background
        if shouldShowMaskView {
            container.addSubview(maskView)
        }

        let scaleFactor: CGFloat = 0.1
        let deltaX = toVc.contentBox.frame.width * (1-scaleFactor)
        let deltaY = toVc.contentBox.frame.height * (1-scaleFactor)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        toVc.contentBox.transform = scale.translatedBy(x: -deltaX, y: deltaY/2.0)

        let finalToViewFrame = toView.frame
        toView.frame = toView.frame.offsetBy(dx: 0, dy: toView.frame.height)
        container.addSubview(toView)

        UIView.spring(duration, animations: {
            maskView.frame = CGRect(x: 0, y: fromFrame.height - 100.0, width: fromFrame.width, height: 120.0)
            toView.frame = finalToViewFrame
            toVc.contentBox.transform = .identity
            toVc.background.alpha = 1.0
        }, completion: { completed in
            // maskView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

class DismissPinAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        guard let fromView = transitionContext.view(forKey: .from) else { assert(false, "Missing from view"); return }
        guard let fromVc = transitionContext.viewController(forKey: .from) as? ContentBoxPresenter else { return }

        UIView.animate(withDuration: duration, animations: {
            fromView.frame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
            fromVc.background.alpha = 0
            
            let scaleFactor: CGFloat = 0.1
            let deltaX = fromVc.contentBox.frame.width * (1-scaleFactor)
            let deltaY = fromVc.contentBox.frame.height * (1-scaleFactor)
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            fromVc.contentBox.transform = scale.translatedBy(x: -deltaX, y: deltaY/2.0)

        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
