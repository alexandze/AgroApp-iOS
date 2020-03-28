//
//  CulturalPraticeViewController.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-03-19.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import UIKit

class CulturalPraticeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var culturalPraticeViewModel: CulturalPraticeViewModel
    let culturalPraticeView: CulturalPraticeView
    let tableView: UITableView

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        culturalPraticeViewModel: CulturalPraticeViewModel
    ) {
        self.culturalPraticeViewModel = culturalPraticeViewModel
        self.culturalPraticeView = CulturalPraticeView()
        self.culturalPraticeViewModel.tableView = self.culturalPraticeView.tableView
        self.tableView = self.culturalPraticeView.tableView
        super.init(nibName: nil, bundle: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.culturalPraticeViewModel.viewController = self
    }

    override func loadView() {
        self.view = self.culturalPraticeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        culturalPraticeViewModel.registerCell()
        culturalPraticeViewModel.registerHeaderFooterViewSection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        culturalPraticeViewModel.subscribeToCulturalPracticeStateObs()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        culturalPraticeViewModel.disposeToCulturalPracticeStateObs()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        culturalPraticeViewModel.getNumberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        culturalPraticeViewModel.getNumberRow(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ""
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: culturalPraticeViewModel.headerFooterSectionViewId)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let element = culturalPraticeViewModel.getCulturePracticeElement(by: indexPath)

        if case CulturalPracticeElement.culturalPracticeInputMultiSelectContainer(_) = element {
            return 350
        }

        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: culturalPraticeViewModel.cellId, for: indexPath) as? SubtitleTableViewCell
        
        switch culturalPraticeViewModel.getCulturePracticeElement(by: indexPath) {
        case .culturalPracticeAddElement(let addElement):
            return culturalPraticeViewModel.initCellFor(addElement: addElement, cell: cell!)

        case .culturalPracticeInputElement(let inputElement):
            return culturalPraticeViewModel.initCellFor(inputElement: inputElement, cell: cell!)

        case .culturalPracticeInputMultiSelectContainer(let inputMultiSelectContainer):
            return culturalPraticeViewModel.initCellFor(containerElement: inputMultiSelectContainer, cell: cell!)
        case .culturalPracticeMultiSelectElement(let multiSelectElement):
            return culturalPraticeViewModel.initCellFor(multiSelectElement: multiSelectElement, cell: cell!)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        culturalPraticeViewModel.handle(didSelectRowAt: indexPath)
    }

}
