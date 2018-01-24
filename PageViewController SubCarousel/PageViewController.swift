import UIKit

class PageViewcontroller: UIPageViewController {
    
    var stackView:UIStackView!
    var imageContainer:UIView!
    var scrollView:UIScrollView?
    
    var prevVC:UIViewController!
    
    func completeTransition() {
        self.pageViewController(self, didFinishAnimating: true, previousViewControllers: self.orderedViewControllers, transitionCompleted: true)
    }
    
    @objc func skipButton(sender: UIBarButtonItem) {
        if let lastViewController = orderedViewControllers.last {
            setViewControllers([lastViewController], direction: .forward, animated: true, completion: { (bool) in
                self.completeTransition()
            })
        }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var vcs = [UIViewController]()
        for i in 0..<colors.count {
            let vc = storyboard!.instantiateViewController(withIdentifier: "Page")
            vcs.append(vc)
        }
        
        return vcs
    }()
    
    var colors = [UIColor.black, UIColor.blue, UIColor.yellow, UIColor.red]
    var colorViews = [UIView]()
    
    var containerHeight:CGFloat = 150
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        func setHeight(element: UIView) {
            let heightConstraint = NSLayoutConstraint(item: element, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: containerHeight)
            element.addConstraint(heightConstraint)
        }
        
        func setRatio(element:UIView) {
            let ratioConstraint = element.heightAnchor.constraint(equalTo: element.widthAnchor, multiplier: 1.0)
            NSLayoutConstraint.activate([ratioConstraint])
        }
        
        func setCenterX(element:UIView) {
            let superView = element.superview!
            let centeRxConstraint = NSLayoutConstraint(item: element, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)
            superView.addConstraint(centeRxConstraint)
        }
        
        func setCenterY(element:UIView) {
            let superView = element.superview!
            let centeRyConstraint = NSLayoutConstraint(item: element, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0)
            superView.addConstraint(centeRyConstraint)
        }
        
        imageContainer = UIView()
        imageContainer.layer.cornerRadius = 34
        imageContainer.clipsToBounds = true
        imageContainer.isUserInteractionEnabled = false
        imageContainer.backgroundColor = UIColor.white
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageContainer)
        setHeight(element: imageContainer)
        setRatio(element: imageContainer)
        setCenterX(element: imageContainer)
        let topAnchor = imageContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([topAnchor])
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        imageContainer.addSubview(stackView)
        setHeight(element: stackView)
        setCenterX(element: stackView)
        setCenterY(element: stackView)
        
        for _ in 0..<3 {
            let colorView = UIView()
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorViews.append(colorView)
            stackView.addArrangedSubview(colorView)
            setRatio(element: colorView)
        }
        
        dataSource = self
        delegate = self
        
        let firstViewController = orderedViewControllers.first
        prevVC = firstViewController
        setViewControllers([firstViewController!], direction: .forward, animated: true, completion: { (bool) in
            self.completeTransition()
        })
        scrollView = view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
        scrollView?.delegate = self
        
        super.viewDidLoad()
    }
}

extension PageViewcontroller: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let vcs = pageViewController.viewControllers {
            if let vc = vcs.first {
                if let viewControllerIndex = orderedViewControllers.index(of: vc) {
                    return viewControllerIndex
                }
            }
            return 0
        }
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

extension PageViewcontroller: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            let vc = viewControllers!.first!
            let vcIndex = orderedViewControllers.index(of: vc)!
            
            for i in 0..<3 {
                let colorView = colorViews[i]
                
                if i == 1 {
                    colorView.backgroundColor = colors[vcIndex]
                }
                else {
                    let vcCount = orderedViewControllers.count - 1
                    
                    if i == 0 && vcIndex != 0 {
                        colorView.backgroundColor = colors[vcIndex - 1]
                    }
                    else if i == 2 && vcCount != vcIndex {
                        colorView.backgroundColor = colors[vcIndex + 1]
                    }
                    else {
                        colorViews[i].backgroundColor = UIColor.clear
                    }
                }
            }
        }
    }
}

extension PageViewcontroller:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        
        let width = scrollView.frame.width
        let normalTransform = contentOffsetX - width
        let percentageTransformed = (normalTransform / width)
        let calc = -(150 * percentageTransformed)
        stackView.transform = CGAffineTransform(translationX: calc, y: 0)
    }
}

