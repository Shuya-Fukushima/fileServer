package com.shiku.file.transfer.domain;

import java.util.ArrayList;
import java.util.List;

public enum FileTransferDomainResult {

	// 特に異常なく成功した場合
	SUCCESS(0),
	// 保存先となる親フォルダが存在しなかった場合
	PARENT_FOLDER_NOT_FOUND(1),
	// ファイル保存に失敗した場合
	FILE_CREATE_FAIL(2),
	// DB関連で失敗した場合
	SQL_EXECUTE_FAIL(3),
	// 漢字半角英字変換で失敗した場合
	GEN_HALFWIDTH_FAIL(4);

	private int result;
	private List<String> files;

	private FileTransferDomainResult(int result) {
		this.result = result;
		this.files = new ArrayList<>();
	}

	public int getResult() {
		return this.result;
	}

	public void setFiles(List<String> files) {
		this.files = files;
	}

	public List<String> getFiles() {
		return this.files;
	}

	public void addFile(String fileName) {
		files.add(fileName);
	}
}
