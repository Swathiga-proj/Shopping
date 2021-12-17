//
//  ViewController.swift
//  Shopping
//
//  Created by NanoNino on 15/12/21.
//

import UIKit
import SDWebImage

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var buttonCart: UIButton!
    
    var isClicked = 0
    var arrList = [ProductList]() 
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        arrList.removeAll()
        getProductList()
    }
    func getProductList(){
        DataManager.shared.getProductList { (result, error) -> (Void) in
            print(result)
            if let error = error{
                print(error.localizedDescription)
            }else{
                for doc in result!{
                    var pro = ProductList()
                   
                    pro.currency_code = doc["currency_code"] as! String
                    pro.description = doc["description"] as! String
                    pro.listing_id = doc["listing_id"] as! String
                    pro.materials = doc["materials"] as! [String:AnyObject]
                    pro.price = doc["price"] as! String
                    pro.title = doc["title"] as! String
                    pro.quantity = doc["quantity"] as! String
                    pro.image = doc["image"] as! String
                    pro.inCart = doc["inCart"] as! Bool
                    pro.doc_id = doc["doc_id"] as! String
                    self.arrList.append(pro)
                    self.collectionView.reloadData()
                }
            }
        }

    }
    
    func addProdToCart(data:[String:AnyObject],id:String){
        DataManager.shared.addToCart(path: id, data: data) { (error) -> (Void) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                print("success")
                self.updateDic(path: id)
            }
        }
        
        
    }
    func updateDic(path:String){
        DataManager.shared.updateProductList(cart: true, path: path) { (error) -> (Void) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                print("success")
                
                self.arrList.removeAll()
                self.getProductList()
            }
        }
    }
//MARK:- collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellList", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let labelProductName = cell.viewWithTag(2) as! UILabel
        let labelPrice = cell.viewWithTag(3) as! UILabel
        let buttonAdd = cell.viewWithTag(4) as! UIButton
        let view = cell.viewWithTag(100) as! UIView
        buttonAdd.addTarget(self, action: #selector(addToCart(_:)), for: .touchUpInside)
        let dic = arrList[indexPath.row]
        view.layer.borderWidth = 0.2
        view.layer.borderColor = UIColor.systemGray.cgColor
        labelProductName.text = dic.title
        labelPrice.text = "₹ "+dic.price
        if dic.inCart == false{
            buttonAdd.setTitle("Add To Cart", for: .normal)
        }else{
            buttonAdd.setTitle("In My Cart", for: .normal)
        }
        imageView.sd_setImage(with: URL(string: dic.image)) { (image, error, cache, url) in
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/2.0
        var yourHeight:CGFloat = 232
        let dic = arrList[indexPath.row]
      //  yourHeight = yourHeight + (dic.title).heightWithConstrainedWidth(yourWidth-20, font: UIFont.systemFont(ofSize: 17.0))
        return CGSize(width: yourWidth, height: yourHeight)

    }
    @objc func addToCart(_ sender: UIButton!){
        
        let point = sender.convert(CGPoint.zero, to: self.collectionView)
        guard let indexpath = collectionView.indexPathForItem(at: point) else { return }

        let dic = arrList[indexpath.row]
//        isClicked = indexpath.row
//        collectionView.reloadItems(at: [IndexPath(item: isClicked, section: 0)])
        
     //   DispatchQueue.main.async {
            
            let dict = ["currency_code":dic.currency_code,"description":dic.description,"image":dic.image,"listing_id":dic.listing_id,"price":dic.price
                        ,"quantity":dic.quantity,"title":dic.title,"materials":dic.materials,"doc_id":dic.doc_id] as [String : AnyObject]
            if sender.titleLabel?.text == "Add To Cart"{
                self.addProdToCart(data: dict, id: dic.doc_id)
            }else{
                let obj = kstoryboard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
                obj.modalPresentationStyle = .fullScreen
                self.present(obj, animated: true, completion: nil)
            }
       // }
    }
    @IBAction func buttonCart(_ sender: Any) {
        let obj = kstoryboard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        obj.modalPresentationStyle = .fullScreen
        self.present(obj, animated: true, completion: nil)

        
    }
}

