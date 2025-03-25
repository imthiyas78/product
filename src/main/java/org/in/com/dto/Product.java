package org.in.com.dto;

import org.springframework.stereotype.Component;

import lombok.Data;

@Data
@Component
public class Product {

	private String code;
	private String name;
	private int weigth;
	private String colour;
	private String manufactureDate;
	private String category;
	
}
