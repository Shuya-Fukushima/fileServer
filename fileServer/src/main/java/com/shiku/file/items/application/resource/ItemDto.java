package com.shiku.file.items.application.resource;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public final class ItemDto {

	/** ファイルID */
	private final long fileId;

	/** ファイル識別子 */
	private final UUID publicId;

	/** 種別（F:ファイル, D:フォルダ） */
	private final String typeCode;

	/** ファイル名 */
	private final String name;

	/** ファイル実体名 */
	private final String physicalName;

	/** ファイル作成日 */
	private final LocalDateTime createAt;
}
