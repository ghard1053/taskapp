//
//  ViewController.swift
//  taskapp
//
//  Created by 水野 隆夫 on 2017/07/23.
//  Copyright © 2017年 ghard1053. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!

  //Realmインスタンスを取得
  let realm = try! Realm()
  
  // DB内のタスクが格納されるリスト。
  // 日付近い順\順でソート：降順
  // 以降内容をアップデートするとリスト内は自動的に更新される。
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

  
  //-------------------------------------------------------------------------------------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.delegate = self
    tableView.dataSource = self
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
    return taskArray.count
  }
  
  //セルの内容を返す
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //再利用可能なcellを得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
    
    //Cellに値を設定する
    let task = taskArray[indexPath.row]
    cell.textLabel?.text = task.title
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let dateString:String = formatter.string(from: task.date as Date)
    cell.detailTextLabel?.text = dateString
    
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
      try! realm.write {
        self.realm.delete(self.taskArray[indexPath.row])
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
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


}

