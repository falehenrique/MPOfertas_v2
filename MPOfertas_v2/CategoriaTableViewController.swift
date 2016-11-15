//
//  CategoriaTableViewController.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 06/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit


class CategoriaTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    //Endpoint
    let categoriasAPIURL = "https://api.mercadopago.com/v0/ofertas/app_categorias"

    var selected = Array<String>()
    
    // Inicializar array de países
    var categorias = [Categoria]()
    
    func getCategorias() {
        guard let categoriaURL = URL(string: categoriasAPIURL) else {
            
            return
        }
        
        let request = URLRequest(url: categoriaURL)

        let urlSession = URLSession.shared

        let task = urlSession.dataTask(with: request, completionHandler : {(data, response, error) -> Void in
            
            if error != nil{
                return
            }
            
            if let data = data {
                self.parseJsonData(data)
                
                // precisa atualizar a interface na main threads
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        })
        
        // 4
        task.resume()
        
        
    }
    
    func parseJsonData(_ data: Data) {
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            // parse json
            let jsonCategorias = jsonResult?["resultsCategoria"] as? [AnyObject]
            
            for jsonCategoria in jsonCategorias! {
                let categoria = Categoria()
                
                categoria.id = jsonCategoria["id_categoria"] as! String
                categoria.descricao = jsonCategoria["nome_categoria"] as! String
                categoria.icone = jsonCategoria["icon"] as! String
                
                categorias.append(categoria)
            }
            
        }catch {
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == nil {
            return
        }
        
        if cell!.accessoryType == .checkmark
        {
            cell!.accessoryType = .none
            if let position = find(elements: selected, toFind: categorias[indexPath.row].id){
                selected.remove(at: position)
            }
        }
        else
        {
            cell!.accessoryType = .checkmark
            
            guard selected.contains(categorias[indexPath.row].id) else {
                selected.append(categorias[indexPath.row].id)
                return
            }
        }

    
    }

    
    func find(elements:Array<String>, toFind:String) -> Int? {
        
        guard elements.count > 0 else {
            return nil
        }
        let max = elements.count - 1
        for i in 0...max {
            if toFind == elements[i] {
                return i
            }
        }
        return nil
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        
//        if cell == nil {
//            return
//        }
//        if let position = find(elements: selected, toFind: categorias[indexPath.row].id){
//            selected.remove(at: position)
//        }
//        
//    }

    override func viewDidAppear(_ animated: Bool) {
        if let valoresSelecionados = InfoLocais.lerArray(chave: "categorias") {
            selected = valoresSelecionados
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        InfoLocais.deletar(chave: "categorias")
 
        if (selected.count > 0)  && selected[0] == ""{
            selected.remove(at: 0)
        }
        InfoLocais.gravarArray(valor: selected, chave: "categorias")    
    }
    
    private func getCategoriasMock() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*if UserDefaults.standard.object(forKey: "categoriasLista") != nil {
            categorias = UserDefaults.standard.object(forKey: "categoriasLista") as! [Categoria]
        } else {
            getCategorias()
        }*/
       
        getCategoriasMock()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categorias.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoria = categorias[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriaCell", for: indexPath) as! CategoriaTableViewCell

        cell.labelDescricao.text = categoria.descricao
        cell.imagemIcone.image = UIImage(named: categoria.icone)
     
        let categoriasSelecionadas = InfoLocais.lerArray(chave: "categorias")

        if let categoriaArmazenadas = categoriasSelecionadas{
            if categoriaArmazenadas.contains(categoria.id) {
                cell.accessoryType = .checkmark
            }
        }
    
        return cell
    }
    
}
