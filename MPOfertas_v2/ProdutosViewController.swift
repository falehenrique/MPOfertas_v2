//
//  ViewController.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 04/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class ProdutosViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var aguarde: UILabel!
    @IBOutlet weak var carregando: UIActivityIndicatorView!
    @IBOutlet weak var imagemCampanha: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    //Endpoint
    let produtoURL = "https://api.mercadopago.com/v0/ofertas/app_produtos"
    
    // Inicializar array de países
    var produtos = [Produto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProdutosViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        
        addImagemTabBar()
        
        getProdutos()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if InfoLocais.lerString(chave: "origem") == "categorias" {
            getProdutos()
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.capturarNotificacoes), name: NSNotification.Name(rawValue: "minhasNotificacoes"), object: nil)
        
    }
    
    func pararCarregando() {
        self.carregando.stopAnimating()
        self.aguarde.isHidden = true
    }
    
    func getProdutos() {
        
        carregando.startAnimating()
        aguarde.isHidden = false
        
        //limpa a tabela
        produtos = [Produto]()
        tableView.reloadData()
        
        print("URL " + produtoURL + definirCategoria())
        
        // validar a conversão da String em URL
        guard let geoURL = URL(string: produtoURL + definirCategoria()) else {
            
            return
        }
        
        
        /*
         1 URL
         2 SESSION
         3 DATA
         4 RESUME
         */
        
        //1
        let request = URLRequest(url: geoURL)
        
        //2
        let urlSession = URLSession.shared
        
        //3
        // A chamada de requisição é assíncrona. Assim que for completada o resultado virá em uma clousure
        
        let task = urlSession.dataTask(with: request, completionHandler : {(data, response, error) -> Void in
            
            if let error = error {
                let alertController = UIAlertController.init(title: "Informação", message: "Não foi possível carregar a lista de produtos", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                self.pararCarregando()
                
                return
            }
            
            if (data != nil) || (data?.count)! > 0 {
                self.parseJsonData(data!)
                
                // precisa atualizar a interface na main threads
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            } else {
                let alertController = UIAlertController.init(title: "Informação", message: "Não foi possível carregar a lista de produtos", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                self.pararCarregando()
                
            }
        })
        
        // 4
        task.resume()
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            self.performSegue(withIdentifier: "segueProduto", sender: self)
        }
    }

    
    func parseJsonData(_ data: Data) {
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            // parse json
            let jsonProdutos = jsonResult?["results"] as? [AnyObject]
            
            if jsonProdutos == nil || (jsonProdutos?.count == 0) {
                let alertController = UIAlertController.init(title: "Informação", message: "Nenhum registro encontrado.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.pararCarregando()
                
                return
            }
            
            var produto = Produto()
            produtos.append(produto)
            for jsonProduto in jsonProdutos! {
                produto = Produto()

                produto.labelNomeProduto = jsonProduto["titulo_produto"] as! String
                produto.labelPercentualDesconto = jsonProduto["desconto"] as! Float
                produto.labelPrecoInicial = jsonProduto["preco_inicial"] as! Float
                produto.labelPrecoFinal = jsonProduto["valor_final"] as! String
                produto.labelCupom = jsonProduto["cupom"] as! String
                
                produto.imagemLogoLoja = jsonProduto["link_imagem_loja"] as! String
                produto.imagemProduto = jsonProduto["link_imagem"] as! String
                
                produto.linkImagem = jsonProduto["link_produto"] as! String
                
                produto.isPreCampanha = jsonProduto["is_pre_campanha"] as! String
                produto.isDestaque = jsonProduto["is_destaque"] as! String
                
                produto.textoCupom = jsonProduto["texto_cupom"] as! String
            
                produtos.append(produto)
                
            }
            
        }catch {
            let alertController = UIAlertController.init(title: "Informação", message: "Não foi possível carregar os produtos.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            print(error)
            self.pararCarregando()
        }
    }
    
    func definirCategoria() -> String {
        var retorno: String = ""
        let categorias = InfoLocais.lerArray(chave: "categorias")
        if categorias != nil && (categorias?.count)! > 0 {
            if categorias?.count == 1{
                retorno = "?p_categorias=" + (categorias?.joined())!
            } else {
                retorno = "?p_categorias=" + (categorias?.joined(separator: ","))!
            }
        }
        
        return retorno
        
    }
    
    
    private func getProdutosMock() {
        do {
            if let file = Bundle.main.url(forResource: "mock_produtos", withExtension: "json") {
                let data = try Data(contentsOf: file)
               parseJsonData(data)
                
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addImagemTabBar(){
 
        let uiImage = UIImage(named: "black_friday_promos")
        
        let imageView = UIImageView(image: uiImage)
        imageView.contentMode  = UIViewContentMode.scaleAspectFit
        
        self.navigationItem.titleView = imageView
    }
    
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        print(userInfo)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return produtos.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.row == 0 {
            let alturaTela = self.view.frame.size.height
            let pontos = calculaPontos(alturaTela)
            
            switch pontos {
            case 5:
                 return 155
            case 6:
                 return 170
            case 7:
                 return 175
            default:
                return 155
            }
        } else {
            return 170.0
        }
    }
    
    /* Calcula o número de pontos que a tela deve subir quando aparecer o teclado
     O número calculado dependerá do tamanho do dispositivo
     iPhone 4/4s -       480.0 pontos de altura
     iPhone 5C   -       548.0 pontos de altura
     iPhone 5/5S -       568.0 pontos de altura
     iPhone 6/6S -       667.0 pontos de altura
     iPhone 6/6s Plus -  736.0 pontos de altura
     iPad (todos) -      1024.0 pontos de altura
     */
    func calculaPontos(_ tamanhoTela: CGFloat) -> Int {
        switch tamanhoTela {
        case 548.0...599.0:
            return 5
        case 600.0...730:
            return 6
        case 736.0...1024.0:
            return 7
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let produto = produtos[indexPath.row]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader", for: indexPath) as! HeaderCellProdutos
            return cell
        }
        
        if produto.isPreCampanha == "N" {
            if produto.isDestaque == "S"{
                return celulaDestaque(produto: produto, indexPath: indexPath)
            } else {
                return celulaNDestaque(produto: produto, indexPath: indexPath)
            }
        }
        
        if indexPath.row == (tableView.indexPathsForVisibleRows?.last)?.row {
            pararCarregando()
        }
        
        return celulaNormal(produto: produto, indexPath: indexPath)
    }
    
    func celulaNDestaque(produto:Produto, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNDestaque", for: indexPath) as! NDestaqueTableViewCell
        
        // Configure the cell...
        
        let produto = produtos[indexPath.row]
        
        cell.labelNomeProduto.text = produto.labelNomeProduto
        
        cell.labelPercentualDesconto.text = String(Int(produto.labelPercentualDesconto)) + "% OFF"
        
        cell.labelPrecoInicial.text = "R$ " + String(produto.labelPrecoInicial).replacingOccurrences(of: ".", with: ",")
        cell.labelPrecoFinal.text = "R$ " + produto.labelPrecoFinal.replacingOccurrences(of: ".", with: ",")
        
        //cell.viewProduto.layer.cornerRadius = 2.0
        cell.imagemLogoLoja.downloadedFrom(link: produto.imagemLogoLoja)
        cell.imagemProduto.downloadedFrom(link: produto.imagemProduto)
        
        cell.imagemLogoLoja.layer.cornerRadius = 10.0
        cell.imagemLogoLoja.layer.masksToBounds = true
        
        cell.imagemProduto.layer.cornerRadius = 10.0
        cell.imagemProduto.layer.masksToBounds = true
        cell.imagemLogoLoja.layer.borderColor = UIColor.lightGray.cgColor

        cell.viewProduto.layer.masksToBounds = true
        cell.viewProduto.layer.cornerRadius = 10.0
        
        cell.labelCupom.attributedText = formatarCupom(textoCupom: produto.textoCupom ,cupom: produto.labelCupom)
        
        return cell
    }

    func formatarCupom(textoCupom:String, cupom:String) -> NSMutableAttributedString{
        
        let textoSize:String = textoCupom + "\n"
        
        let cupomFormatado:String =  textoSize + cupom
        
        let cupomFormatadoRetorno = NSMutableAttributedString(
            string: cupomFormatado,
            attributes: [NSFontAttributeName:UIFont(
                name: "Helvetica",
                size: 11.0)!])
        
        cupomFormatadoRetorno.addAttribute(NSFontAttributeName,
                                     value: UIFont(
                                        name: "Helvetica-Bold",
                                        size: 13.0)!,
                                     range: NSRange(
                                        location: textoSize.characters.count,
                                        length: cupom.characters.count ))
 
        cupomFormatadoRetorno.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor.black,
            range: NSRange(
                location: textoSize.characters.count,
                length: cupom.characters.count))
        
        return cupomFormatadoRetorno
    }
    
    func celulaNormal(produto:Produto, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNormal", for: indexPath) as! NormalTableViewCell
        
        // Configure the cell...
        
        let produto = produtos[indexPath.row]
        
        cell.labelNomeProduto.text = produto.labelNomeProduto
        
        
        cell.imagemLogoLoja.downloadedFrom(link: produto.imagemLogoLoja)
        cell.imagemProduto.downloadedFrom(link: produto.imagemProduto)
        
        cell.imagemLogoLoja.layer.cornerRadius = 10.0
        cell.imagemLogoLoja.layer.masksToBounds = true
        
        cell.imagemProduto.layer.cornerRadius = 10.0
        cell.imagemProduto.layer.masksToBounds = true
        cell.imagemLogoLoja.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.normalView.backgroundColor = UIColor.white
        cell.normalView.layer.masksToBounds = false
        cell.normalView.layer.cornerRadius = 3.0
        cell.normalView.layer.shadowOffset = CGSize.zero
        cell.normalView.layer.shadowOpacity = 0.5
        
        return cell
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func capturarNotificacoes(userInfo: NSNotification) {
    
        let pushCupom = userInfo.value(forKey: "userInfo") as! NSDictionary as! [String: NSObject]

        if pushCupom["title"] as! String == "cupom" {
            
            let alertController = UIAlertController(title: "Parabéns!!!", message: "Você acabou de ganhar um cupom de desconto.", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Fechar", style: .default) { (action:UIAlertAction!) in
                
                let tabArray = self.tabBarController?.tabBar.items as NSArray!
                let tabItem = tabArray?.object(at: 2) as! UITabBarItem
                tabItem.badgeValue = "!"
            
            }
            
            alertController.addAction(OKAction)
            
            self.navigationController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func celulaDestaque(produto:Produto, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDestaque", for: indexPath) as! DestaqueTableViewCell
        
        // Configure the cell...
        
        let produto = produtos[indexPath.row]
        
        cell.labelNomeProduto.text = produto.labelNomeProduto
        
        cell.labelPercentualDesconto.text = String(Int(produto.labelPercentualDesconto)) + "% OFF"
        
        cell.labelPrecoInicial.text = "R$ " + String(produto.labelPrecoInicial).replacingOccurrences(of: ".", with: ",")
        cell.labelPrecoFinal.text = "R$ " + produto.labelPrecoFinal.replacingOccurrences(of: ".", with: ",")

        cell.imagemLogoLoja.downloadedFrom(link: produto.imagemLogoLoja)
        cell.imagemProduto.downloadedFrom(link: produto.imagemProduto)
        
        cell.imagemLogoLoja.layer.masksToBounds = true
        cell.imagemLogoLoja.layer.cornerRadius = 10.0
        
        cell.imagemProduto.layer.masksToBounds = true
        cell.imagemProduto.layer.cornerRadius = 10.0
        
        cell.viewProduto.layer.masksToBounds = true
        cell.viewProduto.layer.cornerRadius = 10.0
        
        cell.imagemLogoLoja.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.labelCupom.attributedText = formatarCupom(textoCupom: produto.textoCupom ,cupom: produto.labelCupom)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueProduto" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                
                let link_produto = produtos[indexPath.row].linkImagem
                    
                let controller = segue.destination as! DetalheProdutoViewController
                    
                controller.urlProduto = link_produto as String?
                    
                InfoLocais.gravarString(valor: "detalheProduto", chave: "origem")
               
                
            }
        } else if segue.identifier == "segueCategorias" {

            InfoLocais.gravarString(valor: "categorias", chave: "origem")
        }
    }

}


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

