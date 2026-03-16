//
//  SideMenuViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/13.
//

import Foundation

protocol SideMenuViewModel {
    var menuList: MenuList? { get }
    var isLoggedIn: Bool { get }
    var isLoading: Bool { get }
    func loadMenuList() async
    func loadIsLoggedIn() async
}

@Observable
final class SideMenuViewModelImpl: SideMenuViewModel {
    var menuList: MenuList?
    var isLoggedIn = false
    var isLoading = false

    private let categoryRepo: CategoryRepository
    private let userRepo: UserRepository

    init(categoryRepo: CategoryRepository, userRepo: UserRepository) {
        self.categoryRepo = categoryRepo
        self.userRepo = userRepo
    }

    func loadMenuList() async {
        Log.vm.debug("SideMenuViewModel.loadMenuList: start")
        isLoading = true
        defer { isLoading = false }
        guard let data = try? await categoryRepo.getCategoryData() else {
            Log.vm.error("SideMenuViewModel.loadMenuList: failed to load categories")
            return
        }
        menuList = MenuList(list: data.list)
        Log.vm.debug("SideMenuViewModel.loadMenuList: success — \(data.list.count) categories")
    }

    func loadIsLoggedIn() async {
        Log.vm.debug("SideMenuViewModel.loadIsLoggedIn: start")
        isLoggedIn = (try? await userRepo.isUserLoggedIn()) ?? false
        Log.vm.debug("SideMenuViewModel.loadIsLoggedIn: isLoggedIn=\(self.isLoggedIn)")
    }
}
