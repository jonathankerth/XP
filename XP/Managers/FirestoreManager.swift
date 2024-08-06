import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    func saveTask(_ task: XPTask, completion: @escaping (Error?) -> Void) {
        do {
            let data = try JSONEncoder().encode(task)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            db.collection("tasks").document(task.id).setData(json) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }

    func fetchTasks(completion: @escaping ([XPTask]?, Error?) -> Void) {
        db.collection("tasks").getDocuments { snapshot, error in
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

    func updateTask(_ task: XPTask, completion: @escaping (Error?) -> Void) {
        do {
            let data = try JSONEncoder().encode(task)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            db.collection("tasks").document(task.id).setData(json) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }

    func deleteTask(_ taskId: String, completion: @escaping (Error?) -> Void) {
        db.collection("tasks").document(taskId).delete { error in
            completion(error)
        }
    }
}
