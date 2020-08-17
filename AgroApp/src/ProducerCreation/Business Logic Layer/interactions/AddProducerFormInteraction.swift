//
//  AddProducerFormInteraction.swift
//  AgroApp
//
//  Created by Alexandre Andze Kande on 2020-08-06.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation

class AddProducerFormInteractionImpl: AddProducerFormInteraction {
    private let actionDispatcher: ActionDispatcher

    init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    func getListElementUIDataWithoutValueAction() {
        _ = Util.runInSchedulerBackground { [weak self] in
            self?.actionDispatcher.dispatch(
                AddProducerFormAction.GetAllElementUIDataWithoutValueAction()
            )
        }
    }

    func setTitleContainerTitleNavigation(title: String) {
        _ = Util.runInSchedulerBackground { [weak self] in
            self?.actionDispatcher.dispatch(
                ContainerTitleNavigationAction.SetTitleAction(title: title)
            )
        }
    }

    func setCurrentViewControllerInNavigation() {
        _ = Util.runInSchedulerBackground { [weak self] in
            self?.actionDispatcher.dispatch(
                ContainerTitleNavigationAction
                    .SetCurrentViewControllerAction(currentViewControllerInNavigation: .culturalPracticeForm)
            )
        }
    }

    func checkIfInputElemenIsValidAction(id: UUID, value: String) {
        _ = Util.runInSchedulerBackground { [weak self] in
            self?.actionDispatcher.dispatch(
                AddProducerFormAction.CheckIfInputElemenIsValidAction(
                    id: id,
                    value: value
                )
            )
        }
    }

    func checkIfAllInputElementIsValidAction() {
        _ = Util.runInSchedulerBackground { [weak self] in
            self?.actionDispatcher.dispatch(
                AddProducerFormAction.CheckIfAllInputElementIsValidAction()
            )
        }
    }

    func addNimInputElementAction() {
        _ = Util.runInSchedulerBackground { [weak self] in
            self?.actionDispatcher.dispatch(
                AddProducerFormAction.AddNimInputElementAction()
            )
        }
    }

    func removeNimInputElementAction(id: UUID) {
        _ = Util.runInSchedulerBackground {
            self.actionDispatcher.dispatch(
                AddProducerFormAction.RemoveNimInputElementAction(id: id)
            )
        }
    }
}

protocol AddProducerFormInteraction {
    func getListElementUIDataWithoutValueAction()
    func setTitleContainerTitleNavigation(title: String)
    func setCurrentViewControllerInNavigation()
    func checkIfInputElemenIsValidAction(id: UUID, value: String)
    func checkIfAllInputElementIsValidAction()
    func addNimInputElementAction()
    func removeNimInputElementAction(id: UUID)
}
