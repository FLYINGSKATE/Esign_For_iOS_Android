import Foundation
import UIKit

class AppCoordinator: BaseCoordinator{
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
    }
    
    override func start() {
        super.start()
        print("funcy")
        navigateToNewsViewController()
    }
    
}

protocol NewsToAppCoordinatorDelegate: class {
    func navigateToFlutterViewController()
}

protocol FlutterToAppCoordinatorDelegate: class {
    func navigateToNewsViewController()
}

extension AppCoordinator: NewsToAppCoordinatorDelegate{
    func navigateToFlutterViewController(){
        let coordinator = FlutterCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: FlutterToAppCoordinatorDelegate{
    func navigateToNewsViewController(){
        print("yo")
        let coordinator = NewsCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
        coordinator.start()
    }
}
