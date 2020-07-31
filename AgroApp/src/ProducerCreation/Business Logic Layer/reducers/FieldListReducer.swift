//
//  FieldListReducer.swift
//  AgroApp
//
//  Created by Alexandre Andze Kande on 2020-07-17.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
import ReSwift

extension Reducers {
    static func fieldListReducer(action: Action, state: FieldListState?) -> FieldListState {
        let state = state ?? FieldListState(uuidState: UUID().uuidString, fieldList: [])

        switch action {
        case let didSelectedFieldOnMapAction as MapFieldAction.DidSelectedFieldOnMapAction:
            return FieldListReducerHandler().handle(didSelectedFieldOnMapAction: didSelectedFieldOnMapAction, state)
        case let didDeselectFieldOnMap as MapFieldAction.DidDelectFieldOnMapAction:
            return FieldListReducerHandler().handle(didDelectFieldOnMapAction: didDeselectFieldOnMap, state)
        case let willSelectFieldOnListAction as FieldListAction.WillSelectFieldOnListAction:
            return FieldListReducerHandler().handle(willSelectFieldOnListAction: willSelectFieldOnListAction, state)
        case let isAppearAction as FieldListAction.IsAppearAction:
            return FieldListReducerHandler().handle(isAppearAction: isAppearAction, state)
        case let updateElementAction as CulturalPracticeFormAction.UpdateCulturalPracticeElementAction:
            return FieldListReducerHandler().handle(
                updateCulturalPracticeElementAction: updateElementAction,
                state
            )
        default:
            return state
        }
    }
}

class FieldListReducerHandler {

    func handle(
        updateCulturalPracticeElementAction : CulturalPracticeFormAction.UpdateCulturalPracticeElementAction,
        _ state: FieldListState
    ) -> FieldListState {
        switch updateCulturalPracticeElementAction.culturalPracticeElementProtocol {
        case let inputElement as CulturalPracticeInputElement:
            return handleUpdateFieldForInputAndSelect(inputElement, updateCulturalPracticeElementAction.field, state)
        case let selectElement as CulturalPracticeMultiSelectElement:
            return handleUpdateFieldForInputAndSelect(selectElement, updateCulturalPracticeElementAction.field, state)
        case let containerElement as CulturalPracticeContainerElement:
            return handleUpdateFieldForContainerElement(
                containerElement,
                updateCulturalPracticeElementAction.field,
                state
            )
        default:
            break
        }
        return state
    }

    private func handleUpdateFieldForInputAndSelect(_ culturalPracticeElement: CulturalPracticeElementProtocol, _ field: Field, _ state: FieldListState) -> FieldListState {
        guard let (fieldFind, indexFind) = findFieldTypeById(state.fieldList!, field.id),
        let culturalPracticeValue = culturalPracticeElement.value
            else { return state }

        let culturalPractice = fieldFind.culturalPratice ?? CulturalPractice(id: fieldFind.id)

        let newCulturalPracticeValue = culturalPracticeValue.changeValueOfCulturalPractice(
            culturalPractice,
            index: culturalPracticeElement.getIndex()
        )

        let fieldNew = fieldFind.set(
            culturalPractice: newCulturalPracticeValue,
            of: fieldFind
        )

        var newFieldList = state.fieldList!
        newFieldList[indexFind] = fieldNew

        return state.changeValue(
            fieldList: newFieldList,
            subAction: .updateFieldSuccess,
            indexForUpdate: indexFind
        )
    }

    private func handleUpdateFieldForContainerElement(
        _ containerElement: CulturalPracticeContainerElement,
        _ field: Field,
        _ state: FieldListState
    ) -> FieldListState {
        // TODO refactoring
        let countInputElement = containerElement.culturalInputElement.count
        var previousState = state
        let countSelectElement = containerElement.culturalPracticeMultiSelectElement.count

        (0..<countInputElement).forEach { index in
            previousState = handleUpdateFieldForInputAndSelect(
                containerElement.culturalInputElement[index], field, previousState
            )
        }

        (0..<countSelectElement).forEach { index in
            previousState = handleUpdateFieldForInputAndSelect(
                containerElement.culturalPracticeMultiSelectElement[index],
                field, previousState
            )
        }

        return previousState
    }

    private func findFieldTypeById(_ fields: [Field],_ id: Int) -> (Field, Int)? {
        let indexFind = fields.firstIndex { $0.id == id }
        return indexFind.map {  (fields[$0], $0) }
    }

    func handle(
        willSelectFieldOnListAction: FieldListAction.WillSelectFieldOnListAction,
        _ state: FieldListState
    ) -> FieldListState {
        let fieldSelected = willSelectFieldOnListAction.field
        return state.changeValue(
            currentField: fieldSelected,
            subAction: .willSelectFieldOnListActionSucccess
        )
    }

    func handle(
        isAppearAction: FieldListAction.IsAppearAction,
        _ state: FieldListState
    ) -> FieldListState {
        state.changeValue(subAction: .isAppearActionSuccess, isAppear: isAppearAction.isAppear)
    }

    func handle(
        didSelectedFieldOnMapAction: MapFieldAction.DidSelectedFieldOnMapAction,
        _ state: FieldListState
        ) -> FieldListState {
        let secondArray = state.fieldList != nil ? state.fieldList! : []
        var firstArray = [didSelectedFieldOnMapAction.field]
        firstArray += secondArray

        return state.changeValue(
            fieldList: firstArray,
            currentField: didSelectedFieldOnMapAction.field,
            subAction: .selectedFieldOnMapActionSuccess
        )
    }

    func handle(
        didDelectFieldOnMapAction: MapFieldAction.DidDelectFieldOnMapAction,
        _ state: FieldListState
    ) -> FieldListState {
        let fieldToRemove = didDelectFieldOnMapAction.field
        let fieldList = state.fieldList ?? []
        let index = findIndexFieldByIdField(idField: fieldToRemove.id, fieldList: fieldList)

        let newFieldListState = index.map { (index: Int) -> FieldListState in
            return handleRemoveFieldInState(state: state, index: index)
        }

        return newFieldListState != nil ? newFieldListState! : state
    }

    private func setCulturalPractice(
        state: CulturalPracticeFormState,
        _ sectionIndex: Int,
        _ inputMultiSelectContainer: CulturalPracticeElementProtocol
    ) -> CulturalPracticeFormState {
        var copyState = state

        copyState.sections![sectionIndex].rowData.append(inputMultiSelectContainer)
        copyState.uuidState = UUID().uuidString
        copyState.subAction = .insertRows(indexPath: [
            IndexPath(
                row: copyState.sections![sectionIndex].rowData.count - 1,
                section: sectionIndex
            )
            ]
        )

        return copyState
    }

    private func handleRemoveFieldInState(state: FieldListState, index: Int) -> FieldListState {
        var fieldArray = state.fieldList
        let removed = fieldArray?.remove(at: index)

        return state.changeValue(
            fieldList: fieldArray,
            currentField: removed,
            indexForRemove: index,
            subAction: .deselectedFieldOnMapActionSuccess
        )
    }

    private func findIndexFieldByIdField(idField: Int, fieldList: [Field]) -> Int? {
        fieldList.firstIndex { $0.id == idField }
    }
}
