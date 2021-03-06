//
//  SelectedFieldRightCalloutView.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-03-04.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import UIKit

class SelectedFieldCalloutView: UIView {
    let tagButtonCancel = 51
    let tagButttonAdd = 50

    private var handleButtonCancelFunc: ((UIButton) -> Void)?
    private var handleButtonAddFunc: ((UIButton) -> Void)?
    var idField: Int?

    let buttonAdd: UIButton = {
        let buttonAdd = UIButton()
        let addImage = UIImage(named: "plus")
        buttonAdd.setImage(addImage, for: .normal)
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        return buttonAdd
    }()

    let buttonCancel: UIButton = {
        let buttonCancel = UIButton()
        let cancelImage = UIImage(named: "stop")
        buttonCancel.setImage(cancelImage, for: .normal)
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        return buttonCancel
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        initView()
    }

    func addTargetButtonCancel(handleCancelFunc: @escaping (UIButton) -> Void) {
        self.handleButtonCancelFunc = handleCancelFunc
        buttonCancel.addTarget(self, action: #selector(handle(buttonCancel:)), for: .touchDown)
    }

    func addTargetButtonAdd(handleAddFunc: @escaping (UIButton) -> Void) {
        self.handleButtonAddFunc = handleAddFunc
        buttonAdd.addTarget(self, action: #selector(handle(addButton:)), for: .touchDown)
    }

    func setStateButton(isSelected: Bool) {
        buttonCancel.isHidden = !isSelected
        buttonAdd.isHidden = isSelected
    }

    private func initView() {
        buttonAdd.tag = tagButttonAdd
        buttonCancel.tag = tagButtonCancel
        addSubview(buttonAdd)
        addSubview(buttonCancel)
        buttonCancel.isHidden = true
        buttonAdd.isHidden = false
        centerInView(button: buttonAdd)
        centerInView(button: buttonCancel)
    }

    @objc private func handle(buttonCancel: UIButton) {
        handleButtonCancelFunc.map {
            $0(buttonCancel)
        }
    }

    @objc private func handle(addButton: UIButton) {
        handleButtonAddFunc.map {
            $0(addButton)
        }
    }

    private func centerInView(button: UIButton) {
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
