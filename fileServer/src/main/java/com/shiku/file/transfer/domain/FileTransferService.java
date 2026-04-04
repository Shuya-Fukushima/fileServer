package com.shiku.file.transfer.domain;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.shiku.file.util.JapaneseToRomaji;
import com.shiku.file.util.db.extention.ExtensionMaster;
import com.shiku.file.util.db.extention.ExtensionMasterRepository;
import com.shiku.file.util.db.file.File;
import com.shiku.file.util.db.file.FileRepository;

@Service
public class FileTransferService {
	@Autowired
	private FileRepository repo;

	@Autowired
	private ExtensionMasterRepository extenRepo;

	/**
	 * ファイルを保存して、DBに登録する
	 * @param parentPath 保存先フォルダのパス
	 * @param parentId 保存先フォルダID
	 * @param files 保存対象ファイル
	 * @return 保存に失敗したファイルリスト
	 * @throws IOException すべて保存に失敗
	 * @throws SQLException SQLで失敗
	 */
	@Transactional
	public List<String> storeFile(Path parentPath, Long parentId, List<MultipartFile> files)
			throws IOException, SQLException {

		// 拡張子マスタからIDに変換するMapオブジェクトを取得する。
		Map<String, Integer> extentionMap = this.getExtentionMaster();

		List<String> failFiles = new ArrayList<>();
		List<File> saveFiles = new ArrayList<>();

		for (MultipartFile file : files) {
			// ファイル名のクリーンアップ（例: test.jpg）
			String fileName = StringUtils.cleanPath(file.getOriginalFilename());

			try {
				// 日本語を半角英数字で構成した物理名に変換
				String physicalName = JapaneseToRomaji.generate(fileName);
				Path targetLocation = parentPath.resolve(physicalName);

				// ファイル保存
				file.transferTo(targetLocation);

				Integer extentionId = extentionMap.get(StringUtils.getFilenameExtension(fileName));

				File saveFile = File.builder()
						.publicId(UUID.randomUUID())
						.typeCode("F")
						.name(fileName)
						.physicalName(physicalName)
						.parentId(parentId)
						.size(file.getSize())
						.extension(String.format("%02d", extentionId != null ? extentionId.intValue() : 0))
						.build();

				saveFiles.add(saveFile);
			} catch (Exception ex) {
				// 作成失敗したファイルを保持
				failFiles.add(fileName);
			}
		}

		// 保存対象がすべてエラーだった場合にエラーとして通知する
		if (failFiles.size() == files.size()) {
			throw new IOException();
		}

		repo.saveAll(saveFiles);

		return failFiles;
	}

	/**
	 * 拡張子をキー、内部IDをバリューとしたMapを取得する。
	 * @return
	 */
	private Map<String, Integer> getExtentionMaster() {
		return extenRepo.findAll().stream().collect(Collectors.toMap(
				extensionMaster -> extensionMaster.getExtension().toLowerCase(),
				ExtensionMaster::getExtensionId));
	}
}
