//
//  ViewController.swift
//  taskapp
//
//  Created by 水野 隆夫 on 2017/07/23.
//  Copyright © 2017年 ghard1053. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var taskSearchBar: UISearchBar!

  //Realmインスタンスを取得
  let realm = try! Realm()
  
  // DB内のタスクが格納されるリスト。
  // 日付近い順\順でソート：降順
  // 以降内容をアップデートするとリスト内は自動的に更新される。
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
  var searchTaskArray = try! Realm().objects(Task.self)
  
  //-------------------------------------------------------------------------------------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.delegate = self
    tableView.dataSource = self
    
    taskSearchBar.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  //------------------------------------------------------------------------------------
  
  
  
  //セルの数を返す
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if taskSearchBar.text != "" {
      return searchTaskArray.count
    } else {
      return taskArray.count
    }

  }
  
  //セルの内容を返す
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //再利用可能なcellを得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
    
    if taskSearchBar.text != "" {
      //Cellに値を設定する
      let task = searchTaskArray[indexPath.row]
      cell.textLabel?.text = task.title
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm"
      
      let dateString:String = formatter.string(from: task.date as Date)
      cell.detailTextLabel?.text = dateString
    } else {
      //Cellに値を設定する
      let task = taskArray[indexPath.row]
      cell.textLabel?.text = task.title
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm"
      
      let dateString:String = formatter.string(from: task.date as Date)
      cell.detailTextLabel?.text = dateString
    }
    
    return cell
  }
  
  //セルを選択した時に実行されるメソッド
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "cellSegue", sender: nil)
  }
  
  //セルが削除可能なことを伝えるメソッド
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.delete
  }
  
  //Deleteの際に呼ばれる
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
      
      //削除されたタスクを取得する
      let task = self.taskArray[indexPath.row]
      
      //ローカル通知をキャンセルする
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
      
      //データベースから削除する
      try! realm.write {
        self.realm.delete(task)
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
      }
      
      //未通知のローカル通知一覧をログ出力
      center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
        for request in requests {
          print("/---------------")
          print(request)
          print("---------------/")
        }
      }
    }
  }
  
  //segueで画面遷移する時に呼ばれる
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let inputViewController:InputViewController = segue.destination as! InputViewController
    
    if segue.identifier == "cellSegue" {
      let indexPath = self.tableView.indexPathForSelectedRow
      inputViewController.task = taskArray[indexPath!.row]
    } else {
      let task = Task()
      task.date = NSDate()
      
      if taskArray.count != 0 {
        task.id = taskArray.max(ofProperty: "id")! + 1
      }
      
      inputViewController.task = task
    }
  }

  //検索ボタンが押された時に呼ばれる
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.view.endEditing(true)
    taskSearchBar.showsCancelButton = true
    searchTaskArray = taskArray.filter("category == '\(taskSearchBar.text!)'")

    self.tableView.reloadData()
  }
  
  //キャンセルボタンが押された時に呼ばれる
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    taskSearchBar.showsCancelButton = false
    self.view.endEditing(true)
    taskSearchBar.text = ""
    self.tableView.reloadData()
  }
  
  // テキストフィールド入力開始前に呼ばれる
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }
  

}

