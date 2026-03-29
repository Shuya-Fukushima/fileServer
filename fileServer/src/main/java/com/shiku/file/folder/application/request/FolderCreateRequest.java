package com.shiku.file.folder.application.request;

import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import lombok.Data;

@Data
public class FolderCreateRequest {

	@Size(min = 36, max = 36, message = "親フォルダIDは0文字以上で入力してください")
	private UUID parentId;
	
	@NotBlank(message = "名前は必須です")
	@Size(max = 255, message = "255文字以内で入力してください")
	private String name;
}
