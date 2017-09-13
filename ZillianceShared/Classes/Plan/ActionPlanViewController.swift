//
//  ActionPlanViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 11-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import PDFGenerator

public class ActionPlanViewController: AnalyzedViewController {
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var notifications: [NotificationTableItemViewModel] = []
    
    fileprivate var audioPlayer: AVAudioPlayer?
    
    var showMeditationCell = false // disabled in TSR

    deinit {
        self.stopAudio()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.separatorColor = UIColor.color(forRed: 249, green: 249, blue: 250, alpha: 1)
        
        self.setupAudioPlayer()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        self.notifications = NotificationsManager.sharedInstance.getNextNotifications()
        self.tableView.reloadData()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTestingNotifications() {

        SVProgressHUD.show(withStatus: "Loading test notifications")

        //first let's purge them all...
        
        let waitingGroup = DispatchGroup()
        
        //calendar notifications
                
        NotificationsManager.sharedInstance.purgeNotifications()
        
        waitingGroup.enter()

        let notification = Notification()
        notification.body = "Reduce the amount of time spent on social media by reading a book instead."
        notification.startDate = Date().addingTimeInterval(60 * 60 * 24 * 2)
        notification.type = .calendar
        
        NotificationsManager.sharedInstance.storeNotification(notification: notification) { (newNotification, error) in
//            waitingGroup.leave()
//
//            
//            waitingGroup.enter()
            
            let notificationC2 = Notification()
            notificationC2.body = "Plan a new trip."
            notificationC2.startDate = Date().addingTimeInterval(60 * 60 * 24 * 5)
            notificationC2.type = .calendar
            
            NotificationsManager.sharedInstance.storeNotification(notification: notificationC2) { (newNotification, error) in
                waitingGroup.leave()
                
            }
            
        }
        

        //local notifications

        
        waitingGroup.enter()

        LocalNotificationsHelper.shared.requestAuthorization(inViewController: self) { (authorized) in
            guard authorized else {
                waitingGroup.leave()

                return
            }
            
            let notificationL = Notification()
            notificationL.body = "Spend more time with my family"
            notificationL.startDate = Date().addingTimeInterval(60 * 60 * 24 * 3)
            notificationL.type = .local
            
            NotificationsManager.sharedInstance.storeNotification(notification: notificationL) { (newNotification, error) in
                
                waitingGroup.leave()
            }
            
            
            waitingGroup.enter()

            let notificationL2 = Notification()
            notificationL2.body = "Go the gym"
            notificationL2.startDate = Date().addingTimeInterval(-60 * 60 * 24 * 10)
            notificationL2.type = .local
            notificationL2.weekDays.append(DayObject(internalValue: .mon))
            notificationL2.weekDays.append(DayObject(internalValue: .wed))
            notificationL2.weekDays.append(DayObject(internalValue: .fri))
            notificationL2.recurrence = .weekly
            
            NotificationsManager.sharedInstance.storeNotification(notification: notificationL2) { (newNotification, error) in
                
                waitingGroup.leave()
            }
            
        }
        
        
        //let's wait, get the latest ones, and reload the table
        
        waitingGroup.notify(queue: DispatchQueue.main) { 
            
            SVProgressHUD.dismiss()
            
            self.notifications = NotificationsManager.sharedInstance.getNextNotifications()
            self.tableView.reloadData()
            
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func shareAction(_ sender: Any?) {

        self.generatePDF { [unowned self] (destinationURL,error) in
            
            if let destinationURL = destinationURL {
                
                let activityViewController = UIActivityViewController(activityItems: [destinationURL] , applicationActivities: nil)
                
                self.present(activityViewController,
                             animated: true,
                             completion: nil)
            }
            else {
                
                //todo handle errors?
                
            }
            
        }
        
    }
    
    func generatePDF(completion: (URL?, Error?) -> ()) {
        
        let planVC = UIStoryboard(name: "Plan", bundle: nil).instantiateViewController(withIdentifier: "ActionPlanViewController") as! ActionPlanViewController
        
        planVC.notifications = notifications
        planVC.showMeditationCell = false
        planVC.view.frame = self.view.frame
        planVC.tableView.reloadData()

        planVC.tableView.layoutIfNeeded()

        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending(("ActionPlan") + ".pdf"))
        
        // writes to Disk directly.
        do {
            try PDFGenerator.generate([planVC.tableView], to: dst)
            
            print("PDF sample saved in: " + dst.absoluteString)
            completion(dst, nil)
            
        } catch (let error) {
            print(error)
            completion(nil, error)
        }
    }
    
    private func setupAudioPlayer() {
        
        let url = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "release-meditation",
            ofType: "mp3")!)
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        // background audio
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch let error as NSError {
            print("audio session error \(error.localizedDescription)")
        }
    }
  }

extension ActionPlanViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0 && showMeditationCell) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeditationPlanCell", for: indexPath) as! MeditationPlanCell
            
            cell.viewContainer.backgroundColor = (self.audioPlayer?.isPlaying ?? false) ? .lightBlue : .white
            
            return cell
            
        }
        else if self.notifications.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
            return cell
        } else {
            
            let item = notifications[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionPlanCell", for: indexPath) as! ActionPlanCell
            cell.configure(item: item)
            
            return cell
        }
        
    }
    
    // First section: mediation cell unless not showing it for pdf generation
    // Second section: notification cells or placeholder if we have none
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.showMeditationCell ? 2 : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0 && self.showMeditationCell) ? 1 : ( self.notifications.count > 0 ? self.notifications.count : 1)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.notifications.count > 0
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let notification = notifications[indexPath.row]
            NotificationsManager.sharedInstance.removeNotification(withId: notification.notificationId)
            
            self.notifications = NotificationsManager.sharedInstance.getNextNotifications()
            self.tableView.reloadData()
            
        }
    }
    
}

extension ActionPlanViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0 && self.showMeditationCell) {
            self.playPauseMeditation()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        guard self.notifications.count > 0 else {
            return
        }

        guard let notification = NotificationsManager.sharedInstance.getNotification(withId: notifications[indexPath.row].notificationId) else {
            assertionFailure()
            return
        }
        
        showNotificationView(notification: notification)

    }
    
    private func showNotificationView(notification: ZillianceShared.Notification) {
        
//        guard let scheduler = UIStoryboard(name: "Schedule", bundle: nil).instantiateInitialViewController() as? ScheduleViewController else {
//            assertionFailure()
//            return
//        }
//        
//        scheduler.preloadedNotification = notification
//                
//        self.navigationController!.pushViewController(scheduler, animated: true)
        
    }
}


extension ActionPlanViewController: AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        
        
    }
    
    func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer?.currentTime = 0
    }
    
    func playPauseMeditation() {
        
        guard let player = self.audioPlayer else {
            return
        }
        
        if !player.isPlaying {
            self.audioPlayer?.play()
        }
        else {
            self.audioPlayer?.stop()
        }
    }

}
