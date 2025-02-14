//
//  favoritesViewController.swift
//  gezilecekYerler
//
//  Created by hasan çiftçi on 27.03.2020.
//  Copyright © 2020 trihay. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class favoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var ref: DatabaseReference!
    var databaseHandle:DatabaseHandle?
    var postData = [String]()
    var favSecilenSehir = ""
    var favSecilenKey = 0
    var postKeyData = [Int]()
      var searchFavSehirler = [String]()
        var searching = false
     @IBOutlet weak var favoritesTable: UITableView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if searching{
                return searchFavSehirler.count
          }else{
              return postData.count
          }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VCTableViewCell
          
               if searching{
                   cell.labelCell.text = searchFavSehirler[indexPath.row]
                   
                  
                   }
               
               else{
                   
               //cell ismi belirler
                  cell.labelCell.text=postData[indexPath.row]
                  
               }
            return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        
        guard let cell = cell as? VCTableViewCell else { return }
        
        cell.animate()
        
    }
    
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          
        
              favSecilenSehir = postData[indexPath.item]
        favSecilenKey = postKeyData[indexPath.item]
             

//        self.ref.child("favorites").queryOrderedByKey().queryEqual(toValue: favSecilenSehir).ref.removeValue()
//
         
          performSegue(withIdentifier: "fav", sender: nil)
      }
    

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if segue.identifier == "fav" {
               
               
               let destinationVC = segue.destination as! favoriteLocationsViewController
               
               // işe yaramaz destinationVC.SegGezilecekYerler=gezilecekYerler
            destinationVC.filtrelenmisFavLocIsmi = favSecilenSehir
          destinationVC.secilmisFavLoc = favSecilenKey
               
           }
           
           
       }
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
              let deneme = UIContextualAction(style: .destructive, title: "Kaldır") { (action, view, nil) in
                
                  var swipedLocation = 0
                  var postDataIndex=0
                let userID = Auth.auth().currentUser?.uid

                  if self.searching{

                      
                      for index in self.postData{
                          if(index == self.searchFavSehirler[indexPath.item].description){
                            swipedLocation = self.postKeyData[postDataIndex]
                       
                             
                              
                          }
                          postDataIndex+=1
                      }
                      
                      


                  }else{
                    swipedLocation = self.postKeyData[indexPath.item]
                      

                     

                  }
                  
              
                
                
                
      //             print(swipedLocation)
      //             print(self.secilmisSehir)
                  
                  self.ref = Database.database().reference()
                 
                         //retrieve post and listen for changes
                 
           
                
                self.ref?.observe(.childRemoved, with: { (snapshot) in
                
                     
               
                    
                    self.ref.child("favorites").child(String(self.favSecilenKey)).child(userID!).removeValue()
               
                    
                       self.favoritesTable.reloadData()
                    
               })
                
                
                           self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                           
                            let post = snapshot.childSnapshot(forPath: "favorites").childSnapshot(forPath: String(swipedLocation)).childSnapshot(forPath: "provinceName").value as? String
                            if post != nil{
                                
                            
                               
                                self.ref.child("favorites").child(String(swipedLocation)).child(userID!).setValue([])
                                   if self.searching{
                                                     self.searchFavSehirler.remove(at: postDataIndex-1)
                                                  }
                                self.postData.remove(at: indexPath.item)
                                self.postKeyData.remove(at: indexPath.item)
                                  self.favoritesTable.reloadData()
                               }
                          })
                
                      }
             

       
               return UISwipeActionsConfiguration(actions: [deneme])
        
          }
          

    
   
    
    

    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(false)
        
          let userID = Auth.auth().currentUser?.uid
        
        postData.removeAll()
        postKeyData.removeAll()
          //set firebase reference
                ref = Database.database().reference().child("favorites")
                      //retrieve post and listen for changes
                ref?.observe(.childAdded, with: { (snapshot) in
                          
                 
                          //code to execute when a child added under Posts
                              let post = snapshot.childSnapshot(forPath: "provinceName").value as? String
                              let postKey = snapshot.key
                    
                               if let actualPost = post{
                                if snapshot.childSnapshot(forPath: userID!).childrenCount>0 {
                                     self.postData.append(actualPost)
                                    self.postKeyData.append(Int(postKey)!)
                                }
        // neden 50 kere   print(self.postKeyData) ??
                                  
                               }
                             self.favoritesTable.reloadData()
                      })
                
//        favoritesTable.reloadData()
              
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("didloaddeneme")
         self.favoritesTable.separatorColor = UIColor.clear
         favoritesTable.dataSource=self
         favoritesTable.delegate=self
        
      
       
              
              
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension favoritesViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        

            searchFavSehirler = postData.filter({$0.prefix(searchText.count)==searchText})
                   searching=true
                   favoritesTable.reloadData()

       
    }
    
}
