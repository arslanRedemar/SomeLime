@testable import Somlimee
import XCTest

final class SideMenuViewModelTests: XCTestCase {
    private var mockCategoryRepo: MockCategoryRepository!
    private var mockUserRepo: MockUserRepository!
    private var sut: SideMenuViewModelImpl!

    override func setUp() {
        super.setUp()
        mockCategoryRepo = MockCategoryRepository()
        mockUserRepo = MockUserRepository()
        sut = SideMenuViewModelImpl(categoryRepo: mockCategoryRepo, userRepo: mockUserRepo)
    }

    func testLoadMenuListPopulatesData() async {
        mockCategoryRepo.getCategoryDataResult = TestFixtures.makeCategoryData()
        await sut.loadMenuList()
        XCTAssertNotNil(sut.menuList)
        XCTAssertEqual(sut.menuList?.list, ["Cat1", "Cat2", "Cat3"])
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadMenuListNilWhenRepoReturnsNil() async {
        mockCategoryRepo.getCategoryDataResult = nil
        await sut.loadMenuList()
        XCTAssertNil(sut.menuList)
        XCTAssertFalse(sut.isLoading)
    }
}
