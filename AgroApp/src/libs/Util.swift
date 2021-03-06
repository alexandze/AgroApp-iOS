//
//  Util.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-28.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import ReSwift

// TODO afficher les messages deinit seulement en mode debug
// TODO deinit les states
// TODO renomer les actionSuccess en actionResponse
// TODO creer dans les actions response une case notResponse
class Util {

    private static var serialDispatchQueueSchedulerForReSwift: SerialDispatchQueueScheduler?
    private static var serialDispatchQueueSchedulerForRequestServer: SerialDispatchQueueScheduler?

    static func getOppositeColorBlackOrWhite() -> UIColor {
        UIColor {(trait: UITraitCollection) -> UIColor in
            switch trait.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .black
            }
        }
    }

    static func getColorBlackOrWhite() -> UIColor {
        UIColor {(trait: UITraitCollection) -> UIColor in
            switch trait.userInterfaceStyle {
            case .dark:
                return .darkText
            default:
                return .white
            }
        }
    }

    static func getBackgroundColor() -> UIColor {
        .systemGray6
    }

    static func getAlphaValue() -> CGFloat {
        0.95
    }

    static public func getSchedulerBackgroundForReSwift() -> SerialDispatchQueueScheduler {
        if serialDispatchQueueSchedulerForReSwift == nil {
            let conQueue = DispatchQueue(label: "com.uqtr.conQueueReSwift", attributes: .concurrent)
            serialDispatchQueueSchedulerForReSwift = SerialDispatchQueueScheduler(queue: conQueue, internalSerialQueueName: "com.uqtr.conQueue")
            return serialDispatchQueueSchedulerForReSwift!
        }

        return serialDispatchQueueSchedulerForReSwift!
    }

    static public func getSchedulerBackgroundForRequestServer() -> SerialDispatchQueueScheduler {
        if serialDispatchQueueSchedulerForRequestServer == nil {
            let conQueue = DispatchQueue(label: "com.uqtr.conQueueRequestServer", attributes: .concurrent)
            serialDispatchQueueSchedulerForRequestServer = SerialDispatchQueueScheduler(queue: conQueue, internalSerialQueueName: "com.uqtr.conQueueRequestServer")
            return serialDispatchQueueSchedulerForRequestServer!
        }

        return serialDispatchQueueSchedulerForRequestServer!
    }

    static func getSchedulerMain() -> MainScheduler {
        MainScheduler.instance
    }

    static public func runInSchedulerMain(_ functionWhoRunInSchedulerMain: @escaping () -> Void) -> Disposable {
        Completable.create { completableEvent in
            functionWhoRunInSchedulerMain()
            completableEvent(.completed)
            return Disposables.create()
        }.subscribeOn(Util.getSchedulerMain())
        .subscribe()
    }

    static public func runInSchedulerBackground(_ functionWhoRunInSchedulerBackground: @escaping () -> Void) -> Disposable {
        Completable.create { completableEvent in
            functionWhoRunInSchedulerBackground()
            completableEvent(.completed)
            return Disposables.create()
        }.subscribeOn(Util.getSchedulerBackgroundForReSwift())
        .subscribe()
    }

    static public func dispatchActionInSchedulerReSwift(_ action: Action, actionDispatcher: ActionDispatcher) {
        _  = runInSchedulerBackground {
            actionDispatcher.dispatch(action)
        }
    }

    static public func createRunCompletable(_ funcRun: @escaping () -> Void) -> Completable {
        Completable.create { completableEvent in
            funcRun()
            completableEvent(.completed)
            return Disposables.create()
        }.subscribeOn(getSchedulerBackgroundForReSwift())
        .observeOn(getSchedulerMain())

    }

    static func getAppDependency() -> AppDependencyContainer? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.appDependencyContainer
    }
    
    static func setRootViewController(_ rootViewController: UIViewController) {
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate
        
        sceneDelegate?.window?.rootViewController = rootViewController
    }

    static func getGreenColor() -> UIColor {
        UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1)
    }

    static func getElementInArrayByIndex<T>(_ array: [T], index: Int) -> T? {
        array.indices.contains(index) ? array[index] : nil
    }

    static func hasIndexInArray<T>(_ array: [T], index: Int) -> Bool {
        return array.count > index
    }
    
    static func filterTValueNotNil<T>(_ tType: T.Type) -> (_ tValue: T?) -> Bool {
    { $0 != nil }
    }
    
    static func mapUnwrapTValue<T>(_ tType: T.Type) -> (_ tValue: T?) -> T {
    { $0! }
    }
    
    static func getMirrorChildrenOfTValue<T>(_ tValue: T) -> Mirror.Children {
        Mirror(reflecting: tValue).children
    }
    
    static func disposeStateObservable(_ disposable: Disposable) {
        _ = Util.runInSchedulerBackground {
            disposable.dispose()
        }
    }
}

precedencegroup CompositionPrecedence {
    associativity: left
}

infix operator >>>: CompositionPrecedence

func >>> <T, U, V>(lhs: @escaping (T) -> U, rhs: @escaping (U) -> V) -> (T) -> V {
    return { rhs(lhs($0)) }
}
