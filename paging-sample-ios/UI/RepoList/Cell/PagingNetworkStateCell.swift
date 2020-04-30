import UIKit

protocol PagingNetworkStateCellDelegate: AnyObject {
    func pagingNetworkStateCellRetryRequested(_ view: UITableViewCell)
}

enum PagingNetworkState {
    case idle, loading, error, reachedLast
    var isIdle: Bool {
        if case .idle = self { return true } else { return false }
    }
}

class PagingNetworkStateCell: UITableViewCell {
    static let identifier = "PagingNetworkStateCell"
    static let cellHeight: CGFloat = 56

    weak var delegate: PagingNetworkStateCellDelegate?

    private let progress = UIActivityIndicatorView(style: .medium)
    private let retryButton = UIButton(type: .system)
    private let reachedLastLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        progress.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progress)
        progress.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        progress.widthAnchor.constraint(equalToConstant: 44).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 44).isActive = true
        progress.isHidden = true

        retryButton.setTitle("再読み込み", for: .normal)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(retryButton)
        retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        retryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        retryButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        retryButton.isHidden = true

        reachedLastLabel.text = "最後です"
        reachedLastLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reachedLastLabel)
        reachedLastLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        reachedLastLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        reachedLastLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        reachedLastLabel.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(delegate: PagingNetworkStateCellDelegate, state: PagingNetworkState) {
        self.delegate = delegate
        switch state {
        case .idle:
            progress.isHidden = true
            retryButton.isHidden = true
            reachedLastLabel.isHidden = true
        case .loading:
            progress.isHidden = false
            retryButton.isHidden = true
            reachedLastLabel.isHidden = true
            progress.startAnimating()
        case .error:
            progress.isHidden = true
            retryButton.isHidden = false
            reachedLastLabel.isHidden = true
        case .reachedLast:
            progress.isHidden = true
            retryButton.isHidden = true
            reachedLastLabel.isHidden = false
        }
    }

    @objc private func onButtonTapped() {
        delegate?.pagingNetworkStateCellRetryRequested(self)
    }
}
