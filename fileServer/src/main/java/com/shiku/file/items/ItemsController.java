package com.shiku.file.items;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.shiku.file.items.application.request.NameUpdateRequest;
import com.shiku.file.items.application.resource.ItemDto;
import com.shiku.file.items.domain.ItemsService;

@RestController
@RequestMapping("/api/items")
public class ItemsController {
	
	@Autowired
	private ItemsService service;

	// A-01: フォルダ配下の一覧取得
	@GetMapping(produces = "application/json; charset=utf-8")
	public ResponseEntity<List<ItemDto>> getItems(@RequestParam String parentId) {
		HttpStatus status = null;
		
		List<ItemDto> items = service.getItems(parentId);
		
		if(items == null)
		{
			status = HttpStatus.INTERNAL_SERVER_ERROR;
		}
		else if(items.size() == 0)
		{
			status = HttpStatus.NOT_FOUND;
		}
		else {
			status = HttpStatus.OK;
		}
		
		return ResponseEntity
	            .status(status)
	            .body(items);
	}

	// A-03: 表示名の変更
	@PatchMapping("/{id}/name")
	public ResponseEntity<Void> updateName(@PathVariable String id, @RequestBody NameUpdateRequest request) {
		return null;
	}

//	// A-08: フォルダ/ファイルの移動
//	@PatchMapping("/{id}/parent")
//	public ResponseEntity<Void> moveItem(@PathVariable String id, @RequestBody MoveRequest request) {
//		return null;
//	}
//
//	// A-09: フォルダ/ファイルの削除
//	@DeleteMapping("/{id}")
//	public ResponseEntity<Void> deleteItem(@PathVariable String id) {
//		return null;
//	}
}