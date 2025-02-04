import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    func saveTask(userID: String, task: XPTask, completion: @escaping (Error?) -> Void) {
        do {
            let data = try JSONEncoder().encode(task)
            var json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            json["xpAwarded"] = task.xpAwarded

            db.collection("users").document(userID).collection("tasks").document(task.id).setData(json) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }

    func fetchTasks(userID: String, completion: @escaping ([XPTask]?, Error?) -> Void) {
        db.collection("users").document(userID).collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                var tasks: [XPTask] = []
                for document in snapshot!.documents {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        var task = try JSONDecoder().decode(XPTask.self, from: jsonData)
                        task.id = document.documentID
                        tasks.append(task)
                    } catch let error {
                        completion(nil, error)
                        return
                    }
                }
                completion(tasks, nil)
            }
        }
    }

    func updateTask(userID: String, task: XPTask, completion: @escaping (Error?) -> Void) {
        do {
            let data = try JSONEncoder().encode(task)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            db.collection("users").document(userID).collection("tasks").document(task.id).setData(json) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }

    func deleteTask(userID: String, taskId: String, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userID).collection("tasks").document(taskId).delete { error in
            completion(error)
        }
    }

    func saveUserXPAndLevel(userID: String, xp: Int, level: Int, rewards: [String], completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "xp": xp,
            "level": level,
            "rewards": rewards
        ]
        db.collection("users").document(userID).setData(userData, merge: true) { error in
            completion(error)
        }
    }

    func fetchUserXPAndLevel(userID: String, completion: @escaping (Int?, Int?, [String]?, Error?) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let xp = data?["xp"] as? Int ?? 0
                let level = data?["level"] as? Int ?? 1
                let rewards = data?["rewards"] as? [String] ?? []
                completion(xp, level, rewards, nil)
            } else {
                completion(nil, nil, nil, error)
            }
        }
    }

    func fetchLevelRewards(userID: String, completion: @escaping ([String]?, Error?) -> Void) {
        db.collection("users").document(userID).collection("rewards").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                var rewards: [String] = []
                for document in snapshot!.documents {
                    if let reward = document.data()["reward"] as? String {
                        rewards.append(reward)
                    }
                }
                completion(rewards, nil)
            }
        }
    }

    func saveLevelReward(userID: String, level: Int, reward: String, completion: @escaping (Error?) -> Void) {
        let rewardData: [String: Any] = [
            "level": level,
            "reward": reward
        ]
        db.collection("users").document(userID).collection("rewards").document("\(level)").setData(rewardData) { error in
            completion(error)
        }
    }

    func saveUserProfile(userID: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName
        ]
        db.collection("users").document(userID).setData(userData, merge: true) { error in
            completion(error)
        }
    }

    func fetchUserProfile(userID: String, completion: @escaping (String?, String?, Error?) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let firstName = data?["firstName"] as? String
                let lastName = data?["lastName"] as? String
                completion(firstName, lastName, nil)
            } else {
                completion(nil, nil, error)
            }
        }
    }

    func saveEarnedXP(userID: String, earnedXP: Int, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "earnedXP": earnedXP
        ]
        db.collection("users").document(userID).setData(userData, merge: true) { error in
            completion(error)
        }
    }

    func fetchEarnedXP(userID: String, completion: @escaping (Int?, Error?) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let earnedXP = data?["earnedXP"] as? Int ?? 0
                completion(earnedXP, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
