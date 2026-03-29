package com.shiku.file.items.application.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import lombok.Data;

@Data
public class NameUpdateRequest {

	@NotBlank(message = "名前は必須です")
	@Size(max = 255, message = "255文字以内で入力してください")
	private String name;
}