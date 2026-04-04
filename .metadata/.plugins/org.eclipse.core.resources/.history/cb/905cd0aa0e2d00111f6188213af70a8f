package com.shiku.file.util.inflastructure.resource;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import lombok.Data;

@Entity
@Table(name = "extension_master", schema = "file_server")
@Data
public class ExtensionMaster {

	/** 内部ID */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "extension_id")
	private Integer extensionId;

	/** 拡張子 */
	@Column(name = "extension", nullable = false)
	private String extension;

	/** 画像フラグ */
	@Column(name = "is_image", nullable = false)
	private Boolean isImage;

	/** バイナリフラグ */
	@Column(name = "is_binary", nullable = false)
	private Boolean isBinary;

	/** 有効フラグ */
	@Column(name = "is_active", nullable = false)
	private Boolean isActive;

	/** 作成日 */
	@Column(name = "created_at", insertable = false, updatable = false)
	private LocalDateTime createdAt;

	/** 更新日 */
	@Column(name = "updated_at", insertable = false)
	private LocalDateTime updatedAt;
}
