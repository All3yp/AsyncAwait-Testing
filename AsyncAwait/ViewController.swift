//
//  ViewController.swift
//  AsyncAwait
//
//  Created by Alley Pereira on 14/06/21.
//

import UIKit

// MARK: - Model
struct User: Codable {
    let name: String
}

class ViewController: UIViewController, UITableViewDataSource {

    enum Errors: Error {
        case failedToGetUsers
    }

    let url = URL(string: "https://jsonplaceholder.typicode.com/users")

    private var users = [User]()

    // MARK: - Table
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.dataSource = self

        async {
            let userResult = await fetchUsers()
            switch userResult {
            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Request
    private func fetchUsers() async -> Result<[User], Error> {
        guard let url = url else {
            return .failure(Errors.failedToGetUsers)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let users = try JSONDecoder().decode([User].self, from: data)
            return .success(users)

        } catch {
            return .failure(error)
        }
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
}
