import UIKit

struct RepoListTableViewDataSourceAdapter {
    enum Section: Int, CaseIterable {
        case item, pagingNetworkState
    }
    enum CellData {
        case item(GithubRepositoryResponse.Item)
        case pagingNetworkState(PagingNetworkState)
    }

    private let viewState: RepoListViewState

    init(viewState: RepoListViewState) {
        self.viewState = viewState
    }

    var numberOfSections: Int {
        return Section.allCases.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = Section(rawValue: section) else { fatalError("Invalid section") }
        switch section {
        case .item:
            return viewState.items.count
        case .pagingNetworkState:
            return 1
        }
    }

    func dataForCell(for indexPath: IndexPath) -> CellData {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Invalid section") }
        switch section {
        case .item:
            return .item(viewState.items[indexPath.row])
        case .pagingNetworkState:
            return .pagingNetworkState(viewState.pagingNetworkState)
        }
    }

    func cellHeight(for indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Invalid section") }
        switch section {
        case .item:
            return RepoCell.cellHeight
        case .pagingNetworkState:
            return PagingNetworkStateCell.cellHeight
        }
    }

    func getIndexPath(of itemId: String) -> IndexPath? {
        guard let row = viewState.items.firstIndex(where: { $0.name == itemId }) else { return nil }
        return IndexPath(row: row, section: Section.item.rawValue)
    }
}
