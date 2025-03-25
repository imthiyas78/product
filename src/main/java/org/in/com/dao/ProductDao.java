package org.in.com.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.in.com.dto.Product;
import org.springframework.stereotype.Repository;

//import org.in.com.dto.UserDTO;

import lombok.Cleanup;

@Repository
public class ProductDao {

	public Product findProduct(int id) {

		Product dto = null;
		try {
			@Cleanup
			Connection connection = ConnectDAO.getConnection();

			@Cleanup
			PreparedStatement namespaceBusPS = connection.prepareStatement(
					"select Id,Code,Name,Weigth,Colour,ManufactureDate,Category from product where Id=?");
			namespaceBusPS.setInt(1, id);

			@Cleanup
			ResultSet selectRS = namespaceBusPS.executeQuery();
			if (selectRS.isBeforeFirst()) {
				dto = new Product();
				selectRS.next();
				dto.setCode(selectRS.getString(2));
				dto.setName(selectRS.getString(3));
				dto.setWeigth(selectRS.getInt(4));
				dto.setColour(selectRS.getString(5));
				dto.setManufactureDate(selectRS.getString(6));
				dto.setCategory(selectRS.getString(7));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dto;
	}

	public void saveProduct(Product product) {

		try {
			@Cleanup
			Connection connection = ConnectDAO.getConnection();

			@Cleanup
			PreparedStatement namespaceBusPS = connection.prepareStatement(
					"insert into product(Code,Name,Weigth,Colour,ManufactureDate,Category)  value(?,?,?,?,?,?)");
			namespaceBusPS.setString(1, generateCode(product.getName()));
			namespaceBusPS.setString(2, product.getName());
			namespaceBusPS.setDouble(3, product.getWeigth());
			namespaceBusPS.setString(4, product.getColour());
			namespaceBusPS.setString(5, product.getManufactureDate());
			namespaceBusPS.setString(6, product.getCategory());
			namespaceBusPS.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void updateProduct(int id, Product product) {

		try {
			@Cleanup
			Connection connection = ConnectDAO.getConnection();

			@Cleanup
			PreparedStatement namespaceBusPS = connection.prepareStatement(
					"update product set Code=?,Name=?,Weigth=?,Colour=?,ManufactureDate=?,Category=? where Id=?");
			namespaceBusPS.setString(1, product.getCode());
			namespaceBusPS.setString(2, product.getName());
			namespaceBusPS.setInt(3, product.getWeigth());
			namespaceBusPS.setString(4, product.getColour());

			namespaceBusPS.setString(5, product.getManufactureDate());
			namespaceBusPS.setString(6, product.getCategory());
			namespaceBusPS.setInt(7, id);
			namespaceBusPS.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void deleteProduct(int id) {

		try {
			@Cleanup
			Connection connection = ConnectDAO.getConnection();

			@Cleanup
			PreparedStatement namespaceBusPS = connection.prepareStatement("delete from product where Id=?");
			namespaceBusPS.setInt(1, id);
			namespaceBusPS.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public List<Product> findProductByName(String name) {
		List<Product> list = null;
		try {
			@Cleanup
			Connection connection = ConnectDAO.getConnection();

			@Cleanup
			PreparedStatement namespaceBusPS = connection.prepareStatement(
					"select Id,Code,Name,Weigth,Colour,ManufactureDate,Category from product where Name like '%' ? '%' ");
			namespaceBusPS.setString(1, name);

			@Cleanup
			ResultSet selectRS = namespaceBusPS.executeQuery();

			if (selectRS.isBeforeFirst()) {
				list = new ArrayList<Product>();
				while (selectRS.next()) {
					Product dto = new Product();
					dto.setCode(selectRS.getString(2));
					dto.setName(selectRS.getString(3));
					dto.setWeigth(selectRS.getInt(4));
					dto.setColour(selectRS.getString(5));
					dto.setManufactureDate(selectRS.getString(6));
					dto.setCategory(selectRS.getString(7));

					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public Product findSingleProductByName(String name) {

		Product dto = null;
		try {
			@Cleanup
			Connection connection = ConnectDAO.getConnection();

			@Cleanup
			PreparedStatement namespaceBusPS = connection.prepareStatement(
					"select Id,Code,Name,Weigth,Colour,ManufactureDate,Category from product where Name=?");
			namespaceBusPS.setString(1, name);

			@Cleanup
			ResultSet selectRS = namespaceBusPS.executeQuery();

			if (selectRS.isBeforeFirst()) {
				dto = new Product();
				selectRS.next();
				dto.setCode(selectRS.getString(2));
				dto.setName(selectRS.getString(3));
				dto.setWeigth(selectRS.getInt(4));
				dto.setColour(selectRS.getString(5));
				dto.setManufactureDate(selectRS.getString(6));
				dto.setCategory(selectRS.getString(7));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dto;
	}

	public String generateCode(String name) {
		int val = (int) (Math.random() * 999) + 999;
		String code = name.substring(0, 3) + String.valueOf(val);
		return code;
	}
}
