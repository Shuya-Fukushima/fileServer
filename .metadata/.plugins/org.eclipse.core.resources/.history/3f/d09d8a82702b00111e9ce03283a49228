package com.shiku.file.util.db.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.shiku.file.util.db.resource.File;
import com.shiku.file.util.db.resource.FilePathProjection;

@Repository
public interface FileRepository extends JpaRepository<File, Long>, JpaSpecificationExecutor<File> {

	@Query(value = """
			WITH recursive file_path(idx, physical_name, parent_id) AS (
			    SELECT
			        0 AS idx
			        , physical_name
			        , parent_id
			    FROM
			        file
			    WHERE
			        file.public_id = :publicId
			    UNION ALL
			    SELECT
			        file_path.idx + 1 AS idx
			        , file.physical_name AS physical_name
			        , file.parent_id AS parent_id
			    FROM
			        file
			        , file_path
			    WHERE
			        file.file_id = file_path.parent_id
			)
			SELECT
			    idx
			    , physical_name
			FROM
			    file_path
			ORDER BY
			    idx DESC
			""", nativeQuery = true)
	List<FilePathProjection> findFilePathList(@Param("publicId") UUID publicId);
}
