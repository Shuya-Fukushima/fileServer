package com.shiku.file.folder;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.shiku.file.folder.application.request.FolderCreateRequest;
import com.shiku.file.folder.application.resource.FolderDto;
import com.shiku.file.folder.domain.FolderDomainResult;
import com.shiku.file.folder.domain.FolderService;
import com.shiku.file.util.db.resource.File;

@RestController
@RequestMapping("/api/folders")
public class FolderController {

	@Autowired
	private FolderService service;

	// A-02: フォルダ作成
	@PostMapping(produces = "application/json; charset=utf-8")
	public ResponseEntity<FolderDto> createFolder(@RequestBody FolderCreateRequest request) {
		FolderDomainResult result = service.createFolder(request.getParentId(), request.getName());

		HttpStatus status = switch (result) {
		case FolderDomainResult.SQL_EXECUTE_FAIL -> HttpStatus.INTERNAL_SERVER_ERROR;
		case FolderDomainResult.GEN_HALFWIDTH_FAIL -> HttpStatus.NOT_ACCEPTABLE;
		case FolderDomainResult.FOLDER_CREATE_FAIL -> HttpStatus.CONFLICT;
		default -> HttpStatus.OK;
		};

		FolderDto folderDto = null;
		File folder = result.getFile();

		if (result.getFile() != null) {
			folderDto = FolderDto.builder()
					.fileId(folder.getFileId())
					.name(folder.getName())
					.physicalName(folder.getPhysicalName())
					.build();
		}

		return ResponseEntity
				.status(status)
				.body(folderDto);
	}

	// A-06: フォルダZIP生成開始（非同期処理のキック）
	//	@PostMapping("/{id}/zip")
	//	public ResponseEntity<JobResponse> startZipJob(@PathVariable String id) {
	//		return null;
	//	}
}