package com.shiku.file.util.db.extention;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface ExtensionMasterRepository
		extends JpaRepository<ExtensionMaster, Integer>, JpaSpecificationExecutor<ExtensionMaster> {
}
