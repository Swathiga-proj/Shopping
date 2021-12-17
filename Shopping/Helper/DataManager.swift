//
//  DataManager.swift
//  Shopping
//
//  Created by NanoNino on 15/12/21.
//

import UIKit
import Firebase
typealias Result = ((_ dataObject:[[String:AnyObject]]?,_ Error:Error?) -> (Void))
class DataManager: NSObject {
    
    static let shared = DataManager()
    
    func getProductList(completion: @escaping Result){
        db.collection("results").getDocuments { (querSnapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }else{
               // print(querSnapshot?.documents.map{$0.data()})
                let res = querSnapshot?.documents.map{$0.data()} as [[String:AnyObject]]
//                for doc in querSnapshot!.documents{
//                    print(doc.data())
//
//                }
                completion(res, err)
            }
        }
    }
    func deleteCart(path:String,completion: @escaping ((_ Error:Error?) -> (Void))){
        db.collection("mycart").document(path).delete { (error) in
            completion(error)
        }
    }
    func updateProductList(cart:Bool,path:String,completion: @escaping ((_ Error:Error?) -> (Void))){
        db.collection("results").document(path).updateData(["inCart":cart]){ (error) in
            completion(error)
        }
    }
    func addToCart(path:String,data:[String:AnyObject],completion: @escaping ((_ Error:Error?) -> (Void))){
        db.collection("mycart").document(path).setData(data) { (error) in
            completion(error)
        }
           
        
    }
    
    func getCartList(completion: @escaping Result){
        db.collection("mycart").getDocuments { (querSnapshot, err) in
            if let err = err{
                print(err.localizedDescription)
            }else{
               // print(querSnapshot?.documents.map{$0.data()})
                let res = querSnapshot?.documents.map{$0.data()} as [[String:AnyObject]]
//                for doc in querSnapshot!.documents{
//                    print(doc.data())
//
//                }
                completion(res, err)
            }
        }

    }
    
    
}


