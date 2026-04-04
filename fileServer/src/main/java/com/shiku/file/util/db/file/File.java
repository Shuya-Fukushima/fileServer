package com.shiku.file.util.db.file;

import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Entity
@Table(name = "file", schema = "file_server")
@Data
@Builder
@AllArgsConstructor
public class File {

	/** ファイルID */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long fileId;

	/** ファイル識別子 */
	@Column(name = "public_id", nullable = false)
	private UUID publicId;

	/** 種別 */
	@Column(name = "type_code", nullable = false, length = 1)
	private String typeCode;

	/** 論理名 */
	@Column(name = "name", nullable = false)
	private String name;

	/** 物理名 */
	@Column(name = "physical_name", nullable = false)
	private String physicalName;

	/** 親フォルダID */
	@Column(name = "parent_id")
	private Long parentId;

	/** ファイルサイズ */
	@Column(name = "size")
	private Long size;

	/** 拡張子 */
	@Column(name = "extension", length = 2)
	private String extension;

	/** 作成日 */
	@Column(name = "created_at", insertable = false, updatable = false)
	private LocalDateTime createdAt;

	/** 更新日 */
	@Column(name = "updated_at", insertable = false)
	private LocalDateTime updatedAt;
}
