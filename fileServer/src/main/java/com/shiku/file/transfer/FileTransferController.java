package com.shiku.file.transfer;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.data.util.Pair;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.shiku.file.transfer.application.resource.UploadResponse;
import com.shiku.file.transfer.domain.FileTransferService;
import com.shiku.file.util.FileUtilService;
import com.shiku.file.util.db.file.File;

@RestController
@RequestMapping("/api")
public class FileTransferController {

	@Autowired
	private FileTransferService service;

	@Autowired
	private FileUtilService fileService;

	// A-04: ファイル/フォルダのアップロード
	@PostMapping(value = "/uploads/{publicId}", produces = "application/json; charset=utf-8")
	public ResponseEntity<UploadResponse> upload(
			@PathVariable UUID publicId,
			@RequestParam List<MultipartFile> files) throws IncorrectResultSizeDataAccessException,
			NullPointerException, IllegalStateException, SQLException, IOException {

		List<String> failList = null;

		Pair<File, Path> pair = fileService.checkExistFile(publicId, false);
		failList = service.storeFile(pair.getSecond(), pair.getFirst().getFileId(), files);

		UploadResponse response = UploadResponse.builder()
				.result(failList != null && failList.size() == 0)
				.failList(failList)
				.build();

		return ResponseEntity
				.status(HttpStatus.CREATED)
				.body(response);
	}

	// A-05: ファイルのダウンロード
	//    @GetMapping("/files/{id}/download")
	//    public ResponseEntity<Resource> downloadFile(@PathVariable String id) { ... }
}