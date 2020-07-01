//
//  MapDependecyContainer.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-02-29.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import ReSwift
import RxSwift
import UIKit

public class MapDependencyContainerImpl: MapDependencyContainer {
    // MARK: - Properties
    let stateStore: Store<AppState>

    init(stateStore: Store<AppState>) {
        self.stateStore = stateStore
    }
    // MARK: - Methods CulturalPracticeForm

    func makeCulturalPracticeFormStateObservalbe() -> Observable<CulturalPracticeFormState> {
        self.stateStore.makeObservable { (subscription: Subscription<AppState>) -> Subscription<CulturalPracticeFormState> in
            subscription
                .select { $0.culturalPracticeFormState }
                .skip { $0.uuidState == $1.uuidState }
        }
    }

    func makeCulturalPracticeFormViewModel() -> CulturalPracticeFormViewModel {
        CulturalPracticeFormViewModelImpl(
            culturalPracticeFormObs: makeCulturalPracticeFormStateObservalbe(),
            actionDispatcher: stateStore
        )
    }

    public func makeCulturalPracticeFormController() -> CulturalPracticeFormViewController {
        CulturalPracticeFormViewController(culturalPracticeFormViewModel: makeCulturalPracticeFormViewModel())
    }

    // MARK: - Methodes Map

    func makeMapFieldAllStateObservable() -> Observable<MapFieldState> {
        self.stateStore.makeObservable(
            transform: {(subscription: Subscription<AppState>) -> Subscription<MapFieldState> in
            subscription
                .select { $0.mapFieldState.mapFieldAllFieldsState }
                .skip { $0.uuidState == $1.uuidState }
        })
    }

    func createMapFieldInteraction() -> MapFieldInteraction {
        MapFieldInteractionImpl(actionDispatcher: self.stateStore)
    }

    func makeMapFieldViewModel() -> MapFieldViewModel {
        let observable = makeMapFieldAllStateObservable()
        let interaction = createMapFieldInteraction()
        return MapFieldViewModel(mapFieldAllFieldStateObs: observable, mapFieldInteraction: interaction)
    }

    func makeMapFieldViewController() -> MapFieldViewController {
        let viewModel = makeMapFieldViewModel()
        let viewController = MapFieldViewController(mapFieldViewModel: viewModel)
        return viewController
    }

    // MARK: - Methods FieldList

    func makeFieldListStateObservable() -> Observable<FieldListState> {
        self.stateStore.makeObservable(
            transform: {(subscription: Subscription<AppState>) -> Subscription<FieldListState> in
            subscription
                .select { appState in
                appState.mapFieldState.fieldListState
            }.skip { $0 == $1 }
        })
    }

    func makeFieldListInteraction() -> FieldListInteraction {
        FieldListInteractionImpl(actionDispatcher: self.stateStore)
    }

    func makeFieldListViewModel() -> FieldListViewModel {
        return FieldListViewModelImpl(
            fieldListStateObs: self.makeFieldListStateObservable(),
            actionDispatcher: self.stateStore
        )
    }

    public func makeFieldListViewController() -> FieldListViewController {
        FieldListViewController(fieldListViewModel: makeFieldListViewModel())
    }

    // MARK: - Methods FieldCultural

    func makeCurrentFieldObservable() -> Observable<CulturalPracticeState> {
        self.stateStore.makeObservable(
            transform: {(subscription: Subscription<AppState>) -> Subscription<CulturalPracticeState> in
            subscription
                .select { appState in
                    appState.culturalPracticeState
            }
            .skip { $0 == $1 }
        })
    }

    func makeCulturalPracticeInteraction() -> FieldCulturalPracticeInteraction {
        FieldCulturalPracticeInteractionImpl(actionDispatcher: self.stateStore)
    }

    func makeCulturalPracticeViewModel() -> CulturalPraticeViewModel {
        CulturalPraticeViewModelImpl(
            culturalPracticeStateObs: self.makeCurrentFieldObservable(),
            actionDispatcher: self.stateStore
        )
    }

    public func makeCulturalPracticeViewController() -> CulturalPraticeViewController {
        CulturalPraticeViewController(culturalPraticeViewModel: self.makeCulturalPracticeViewModel())
    }

    func makeContainerFieldNavigationViewController() -> ContainerFieldNavigationViewController {
        ContainerFieldNavigationViewController(navigationFieldController: makeFieldListNavigationController())
    }

    // MARK: - Methods navigation
    public func makeFieldListNavigationController() -> UINavigationController {
        UINavigationController(rootViewController: self.makeFieldListViewController())
    }

    public func makeMapFieldNavigationController() -> UINavigationController {
        let navController = UINavigationController(rootViewController: self.makeMapFieldViewController())
        let tabBarItem = UITabBarItem(title: "Carte", image: UIImage(named: "mapsIcon"), tag: 2)
        navController.tabBarItem = tabBarItem
        return navController
    }

    // MARK: - Methods process
    public func processInitMapField() -> UINavigationController {
        makeMapFieldNavigationController()
    }

    public func processInitFieldListNavigation() -> UINavigationController {
        makeFieldListNavigationController()
    }

    public func processInitContainerMapAndFieldNavigation() -> ContainerMapAndListFieldViewController {
        ContainerMapAndListFieldViewController(
            mapFieldViewController: makeMapFieldViewController(),
            containerFieldNavigationViewController: makeContainerFieldNavigationViewController()
        )
    }

}

public protocol MapDependencyContainer {
    func makeMapFieldNavigationController() -> UINavigationController
    func makeFieldListNavigationController() -> UINavigationController
    func makeCulturalPracticeViewController() -> CulturalPraticeViewController
    func makeFieldListViewController() -> FieldListViewController
    func processInitContainerMapAndFieldNavigation() -> ContainerMapAndListFieldViewController
    func processInitMapField() -> UINavigationController
    func makeCulturalPracticeFormController() -> CulturalPracticeFormViewController

}