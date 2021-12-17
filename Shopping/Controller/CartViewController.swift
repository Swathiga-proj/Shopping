//
//  CartViewController.swift
//  Shopping
//
//  Created by NanoNino on 15/12/21.
//

import UIKit
import SDWebImage
class CartViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    

   var arrList = [ProductList]()
    @IBOutlet var labelSubTotal: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var emptyView: UIImageView!
    var total = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView.isHidden = false
        collectionView.delegate = self
        collectionView.dataSource = self
        arrList.removeAll()
        getList()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCart", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let labelProductName = cell.viewWithTag(2) as! UILabel
        let labelPrice = cell.viewWithTag(3) as! UILabel
        let labelQuantity = cell.viewWithTag(4) as! UILabel
        let buttonDelete = cell.viewWithTag(5) as! UIButton
        buttonDelete.addTarget(self, action: #selector(addToCart(_:)), for: .touchUpInside)

        let dic = arrList[indexPath.row]
        cell.backgroundColor = UIColor.gray
        imageView.sd_setImage(with: URL(string: dic.image)) { (image, error, cache, url) in
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
        labelPrice.text = "₹ "+dic.price
        let p = dic.price
        total = total + Int(Float(p)!)
        labelProductName.text = dic.title
        labelQuantity.text = "Quantity: \(dic.quantity)"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //    let yourWidth = collectionView.bounds.width
        let width = view.frame.size.width

        var yourHeight:CGFloat = 140
        let dic = arrList[indexPath.row]
      //  yourHeight = yourHeight + (dic.title).heightWithConstrainedWidth(yourWidth-20, font: UIFont.systemFont(ofSize: 17.0))
        return CGSize(width: width, height: yourHeight)

    }
    @objc func addToCart(_ sender: UIButton!){
        
        let point = sender.convert(CGPoint.zero, to: self.collectionView)
        guard let indexpath = collectionView.indexPathForItem(at: point) else { return }

        let dic = arrList[indexpath.row]
        if dic.doc_id != nil{
        delete(path: dic.doc_id)
        }
    }
    func delete(path:String){
        DataManager.shared.deleteCart(path: path) { (error) -> (Void) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                self.updateDic(path: path)
            }
        }
    }
    func updateDic(path:String){
        DataManager.shared.updateProductList(cart: false, path: path) { (error) -> (Void) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                self.arrList.removeAll()
                self.getList()
            }
        }

    }

    func getList(){
        DataManager.shared.getCartList { (res, error) -> (Void) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                if res!.count>0{
                for doc in res!{
                    var pro = ProductList()
                   
                    pro.currency_code = doc["currency_code"] as! String
                    pro.description = doc["description"] as! String
                    pro.listing_id = doc["listing_id"] as! String
                    pro.materials = doc["materials"] as! [String:AnyObject]
                    pro.price = doc["price"] as! String
                    pro.title = doc["title"] as! String
                    pro.quantity = doc["quantity"] as! String
                    pro.image = doc["image"] as! String
                    pro.doc_id = doc["doc_id"] as! String
                    self.arrList.append(pro)
                        self.emptyView.isHidden = true
                    self.collectionView.reloadData()
                    self.collectionView.performBatchUpdates(nil) { (finish) in
                        if finish{
                            self.labelSubTotal.text = "Total Price: " + "₹ " + String(self.total)
                        }
                    }
                    
                }
                }else{
                    self.emptyView.isHidden = false
                }
            }
        }
    }
    @IBAction func buttonBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func proceedToBuy(_ sender: Any) {
    }
}
