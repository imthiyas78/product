package org.in.com.service.impl;

import java.util.List;


import org.in.com.dao.ProductDao;
import org.in.com.dto.Product;
import org.in.com.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProductServiceImpl implements ProductService {

	@Autowired
	private ProductDao dao;

	@Override
	public Product findProduct(int id) {

		return dao.findProduct(id);
	}

	@Override
	public void saveProduct(Product product) {

		dao.saveProduct(product);
	}

	@Override
	public void updateProduct(int id, Product product) {

		dao.updateProduct(id, product);
	}

	@Override
	public Product deleteProduct(int id) {

		Product dbProduct = dao.findProduct(id);

		//checking the product is present to delete
		if (dbProduct != null) {

			dao.deleteProduct(id);
		}
		return dbProduct;
	}

	@Override
	public List<Product> findProductByName(String name) {
		
		return dao.findProductByName(name);
	}

	@Override
	public Product findSingledProductByName(String name) {
	
		return dao.findSingleProductByName(name);
	}
}
