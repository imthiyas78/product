package org.in.com.controller;

import java.util.List;

import org.in.com.dto.Product;
import org.in.com.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/product")
public class ProductController {

	@Autowired
	private ProductService service;
	
	@RequestMapping(value = "/find",method = RequestMethod.GET,produces = { MediaType.APPLICATION_JSON_VALUE })
	@ResponseBody
	public Product findProduct(@RequestParam int id) {
	return service.findProduct(id);	
	}
	
	@RequestMapping(value = "/save",method = RequestMethod.POST,produces = { MediaType.APPLICATION_JSON_VALUE })
	@ResponseBody
	public Product saveProduct(@RequestBody Product product) {
		service.saveProduct(product);	
		return product;
	}
	
	@RequestMapping(value = "/update",method = RequestMethod.POST,produces = { MediaType.APPLICATION_JSON_VALUE })
	@ResponseBody
	public Product updateProduct(@RequestParam int id, @RequestBody Product product) {
		service.updateProduct(id,product);		
		return product;
	}
	
	@RequestMapping(value = "/delete",method = RequestMethod.GET,produces = { MediaType.APPLICATION_JSON_VALUE })
	@ResponseBody
	public Product deleteProductById(@RequestParam int id) {
		
		return service.deleteProduct(id);
	}
	
	@RequestMapping(value = "/findbyname",method = RequestMethod.GET,produces = { MediaType.APPLICATION_JSON_VALUE })
	@ResponseBody
	public List<Product> findProductByName(@RequestParam String name) {
		return service.findProductByName(name);	
	}
	
	@RequestMapping(value = "/findproductbyname",method = RequestMethod.GET,produces = { MediaType.APPLICATION_JSON_VALUE })
	@ResponseBody
	public Product findSingleProductByName(@RequestParam String name) {
		return service.findSingledProductByName(name);	
	}
}
