package org.in.com.service;

import java.util.List;

import org.in.com.dto.Product;

public interface ProductService {

	Product findProduct(int id);

	void saveProduct(Product product);

	void updateProduct(int id, Product product);

	Product deleteProduct(int id);

	List<Product> findProductByName(String name);

	Product findSingledProductByName(String name);	
}
