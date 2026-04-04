package com.shiku.file.folder.domain;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.shiku.file.util.JapaneseToRomaji;
import com.shiku.file.util.db.file.File;
import com.shiku.file.util.db.file.FileRepository;

@Service
public class FolderService {

	@Autowired
	private FileRepository fileRepo;

	/**
	 * フォルダを作成する。
	 * @param parentPath 親フォルダのパス
	 * @param parentId 親フォルダID
	 * @param name フォルダ名
	 * @return 作成されたフォルダ
	 * @throws IllegalArgumentException 日本語変換に失敗
	 * @throws IOException フォルダ作成に失敗
	 * @throws SQLException SQLで失敗
	 */
	public File createFolder(Path parentPath, Long parentId, String name)
			throws IllegalArgumentException, IOException, SQLException {

		// 日本語を半角英数字で構成した物理名に変換
		String physicalName = null;
		try {
			physicalName = JapaneseToRomaji.generate(name);
		} catch (Exception e) {
			throw new IllegalArgumentException();
		}

		// フォルダを作成する
		if (!parentPath.resolve(physicalName).toFile().mkdir()) {
			throw new IOException();
		}

		// 作成したフォルダをDBに登録する
		File folder = File.builder()
				.publicId(UUID.randomUUID())
				.typeCode("D")
				.name(name)
				.physicalName(physicalName)
				.parentId(parentId)
				.build();

		folder = fileRepo.save(folder);

		return folder;
	}
}
