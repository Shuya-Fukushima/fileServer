package com.shiku.file.transfer.domain;

public enum FileTransferDomainResult {

	// 特に異常なく成功した場合
	SUCCESS(0),
	// ファイル保存に失敗した場合
	FILE_CREATE_FAIL(1),
	// DB関連で失敗した場合
	SQL_EXECUTE_FAIL(2),
	// 漢字半角英字変換で失敗した場合
	GEN_HALFWIDTH_FAIL(3),
	// 存在しないフォルダが指定されていた場合
	NOT_EXIST(4),
	// データ不整合
	DATA_INCONSISTENCY(5),
	;

	private int result;

	private FileTransferDomainResult(int result) {
		this.result = result;
	}

	public int getResult() {
		return this.result;
	}
}
