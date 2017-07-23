//
//  InputViewController.swift
//  taskapp
//
//  Created by 水野 隆夫 on 2017/07/23.
//  Copyright © 2017年 ghard1053. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {

  @IBOutlet weak var titleTextField: UITextField!
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
      contentsTextView.text = task.contents
      datePicker.date = task.date as Date
      
    }
  
    override func viewWillDisappear(_ animated: Bool) {
      try! realm.write {
        self.task.title = self.titleTextField.text!
        self.task.contents = self.contentsTextView.text
        self.task.date = self.datePicker.date as NSDate
        self.realm.add(self.task, update: true)
      }
      
      super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  func dismissKeyboard() {
    view.endEditing(true)
  }

}
