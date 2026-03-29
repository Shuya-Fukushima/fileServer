package com.shiku.file.job;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/zip-jobs")
public class JobController {

    // A-07: ZIP生成の進捗取得
//    @GetMapping("/{jobId}")
//    public ResponseEntity<JobStatusDto> getJobStatus(@PathVariable String jobId) { ... }
}