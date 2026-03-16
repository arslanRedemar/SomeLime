//
//  PsyTestListViewModel.swift
//  Somlimee
//

import Foundation

protocol PsyTestListViewModel {
    var testItems: [PsyTestItem] { get }
    var isLoading: Bool { get }
    func loadTests() async
}

@Observable
final class PsyTestListViewModelImpl: PsyTestListViewModel {
    var testItems: [PsyTestItem] = []
    var isLoading = false

    func loadTests() async {
        Log.vm.debug("PsyTestListViewModel.loadTests: start")
        isLoading = true
        defer { isLoading = false }

        testItems = [
            PsyTestItem(
                id: "somlime_personality",
                name: "SomLiMe 성격 테스트",
                description: "4가지 축(활력성, 수용성, 조화성, 결집성)을 기반으로 당신의 성격 유형을 분석합니다.",
                questionCount: 5,
                estimatedMinutes: 3,
                imageName: "NDR"
            )
        ]
        Log.vm.debug("PsyTestListViewModel.loadTests: loaded \(self.testItems.count) tests")
    }
}
