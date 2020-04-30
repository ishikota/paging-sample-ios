import UIKit
import RxCocoa
import RxSwift

class RepoListViewController: UIViewController {
    private var viewModel: RepoListViewModel!
    private var tableViewDataSourceAdapter = RepoListTableViewDataSourceAdapter(viewState: .empty)
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()

    private let disposeBag = DisposeBag()
    var fetchTrigger: Signal<Void> { return fetchRelay.asSignal() }
    private let fetchRelay = PublishRelay<Void>()
    var duplicatableLoadMoreTrigger: Signal<Void> { return duplicatableLoadMoreRelay.asSignal() }
    private let duplicatableLoadMoreRelay = PublishRelay<Void>()
    var retryTrigger: Signal<Void> { return retryRelay.asSignal() }
    private let retryRelay = PublishRelay<Void>()
    var refreshTrigger: Signal<Void> { return refreshRelay.asSignal() }
    private let refreshRelay = PublishRelay<Void>()
    var updateLikeTrigger: Signal<String> { return updateLikeRelay.asSignal() }
    private let updateLikeRelay = PublishRelay<String>()

    func inject(viewModel: RepoListViewModel) {
        self.viewModel = viewModel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRelay.accept(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // setup view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.register(RepoCell.self, forCellReuseIdentifier: RepoCell.identifier)
        tableView.register(PagingNetworkStateCell.self, forCellReuseIdentifier: PagingNetworkStateCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)

        viewModel.viewState
            .drive(onNext: { [weak self] viewState in
                guard let self = self else { return }
                self.tableViewDataSourceAdapter = RepoListTableViewDataSourceAdapter(viewState: viewState)

                switch viewState.mutatingContext {
                case .initialized:
                    self.tableView.reloadData()
                case .fetchItems:
                    self.tableView.reloadData()
                case .refreshItems:
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                case let .updateLike(updateInfo):
                    if let indexPathToUpdate = self.tableViewDataSourceAdapter.getIndexPath(of: updateInfo.id) {
                        self.tableView.reloadRows(at: [indexPathToUpdate], with: .none)
                    }
                }
            }).disposed(by: disposeBag)
    }

    @objc private func pullToRefresh() {
        refreshRelay.accept(())
    }
}

extension RepoListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewDataSourceAdapter.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSourceAdapter.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewDataSourceAdapter.dataForCell(for: indexPath)
        switch data {
        case let .item(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RepoCell.identifier) as? RepoCell else {
                fatalError()
            }
            cell.configure(with: item)
            cell.delegate = self
            return cell
        case let .pagingNetworkState(state):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PagingNetworkStateCell.identifier) as? PagingNetworkStateCell else {
                fatalError()
            }
            cell.configure(delegate: self, state: state)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewDataSourceAdapter.cellHeight(for: indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let y = scrollView.contentOffset.y + scrollView.contentInset.top
        let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
        if y > threshold {
            duplicatableLoadMoreRelay.accept(())
        }
    }
}

extension RepoListViewController: RepoCellDelegate {
    func repoCell(_ view: UITableViewCell, likeUpdateRequestedFrom repoID: String) {
        updateLikeRelay.accept(repoID)
    }
}

extension RepoListViewController: PagingNetworkStateCellDelegate {
    func pagingNetworkStateCellRetryRequested(_ view: UITableViewCell) {
         fetchRelay.accept(())
    }
}
