//
//  ContainerTitleNavigationView.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-02-28.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import UIKit

/// Container who content Title and navigation view. The navigation view is for list field and cultural practice form
class ContainerTitleNavigationView: UIView {
    public static let VIEW_TAG = 80
    var titleView: TitleView?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        configView()
        initViewTitle(parentView: self)
    }

    func hideCloseButton() {
        titleView?.hideCloseButton()
    }

    func printCloseButton() {
        titleView?.printCloseButton()
    }

    func setTitle(_ title: String) {
        titleView?.setTitle(title)
    }

    func initHandlerCloseButton(handlerCloseButton: @escaping () -> Void) {
        titleView?.initHandleCloseButton {
            handlerCloseButton()
        }
    }

    func initNavigationControllerView(navigationControllerView: UIView) {
        let titleView = viewWithTag(1)!
        navigationControllerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationControllerView)

        NSLayoutConstraint.activate([
            navigationControllerView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            navigationControllerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationControllerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationControllerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func initViewTitle(parentView: UIView) {
        titleView = TitleView()
        titleView!.clipsToBounds = true
        titleView!.tag = 1
        titleView!.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(titleView!)

        NSLayoutConstraint.activate([
            titleView!.topAnchor.constraint(equalTo: parentView.topAnchor),
            titleView!.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            titleView!.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            titleView!.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func configView() {
        clipsToBounds = true
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
}
