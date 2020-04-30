import UIKit

protocol RepoCellDelegate: AnyObject {
    func repoCell(_ view: UITableViewCell, likeUpdateRequestedFrom repoID: String)
}

class RepoCell: UITableViewCell {
    static let identifier = "RepoCell"
    static let cellHeight: CGFloat = 100
    
    weak var delegate: RepoCellDelegate?

    private let label = UILabel()
    private let likeButton = UIButton(type: .system)
    private var item: GithubRepositoryResponse.Item?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 44).isActive = true

        likeButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likeButton)
        likeButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
            fatalError()
        }

    func configure(with item: GithubRepositoryResponse.Item) {
        label.text = item.name
        likeButton.setTitle(item.liked ? "Unlike" : "Like", for: .normal)
        self.item = item
        likeButton.isEnabled = true
    }

    @objc private func onButtonTapped() {
        guard let item = item else { return }
        delegate?.repoCell(self, likeUpdateRequestedFrom: item.name)
        likeButton.isEnabled = false
    }
}
