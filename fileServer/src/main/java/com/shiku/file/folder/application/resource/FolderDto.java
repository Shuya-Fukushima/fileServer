package com.shiku.file.folder.application.resource;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class FolderDto {

	/** ファイルID */
	private final long fileId;

	/** ファイル名 */
	private final String name;

	/** ファイル実体名 */
	private final String physicalName;
}
