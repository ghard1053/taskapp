//
//  InputViewController.swift
//  taskapp
//
//  Created by 水野 隆夫 on 2017/07/23.
//  Copyright © 2017年 ghard1053. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  var task: Task!
  let realm = try! Realm()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      //背景タップ、dismissKeyboardメソッドを呼ぶ
      let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
      self.view.addGestureRecognizer(tapGesture)
      
      titleTextField.text = task.title
      categoryTextField.text = task.category
      contentsTextView.text = task.contents
      datePicker.date = task.date as Date
      
    }
  
    override func viewWillDisappear(_ animated: Bool) {
      try! realm.write {
        self.task.title = self.titleTextField.text!
        self.task.category = self.categoryTextField.text!
        self.task.contents = self.contentsTextView.text
        self.task.date = self.datePicker.date as NSDate
        self.realm.add(self.task, update: true)
      }
      
      setNotification(task: task)
      
      super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  //taskのローカル通知を登録する
  func setNotification(task: Task) {
    let content = UNMutableNotificationContent()
    content.title = task.title
    content.body = task.contents
    content.sound = UNNotificationSound.default()
    
    //ローカル通知が発動するtrigger(日付マッチ)を作成
    let calender = NSCalendar.current
    let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
    let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    
    //identifer, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
    let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
    
    //ローカル通知を登録
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
      print(error ?? "ローカル通知登録 OK") // error が nil ならローカル通知の登録に成功したと表示。errorが存在すればerrorを表示。
    }
    
    //未通知のローカル通知一覧をログ出力
    center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
      for request in requests {
        print("/--------------")
        print(request)
        print("--------------/")
      }
    }
  }

}
