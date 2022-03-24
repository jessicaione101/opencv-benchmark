source("plot.r")

results <- list(
	list("No optimization", "raw_hog_no-optimization_2019-12-10--16-05-11.txt"),
	list("AVX2", "raw_hog_avx2_2019-12-10--16-07-56.txt"),
	list("AVX2 + IPP", "raw_hog_avx2-ipp_2019-12-10--16-09-16.txt"),
	list("OpenMP", "raw_hog_openmp_2019-12-10--16-06-07.txt"),
	list("pthreads", "raw_hog_pthreads_2019-12-10--16-05-39.txt"),
	list("TBB", "raw_hog_tbb_2019-12-10--16-06-39.txt"),
	list("AVX2 + OpenMP", "raw_hog_avx2-openmp_2019-12-10--16-09-56.txt"),
	list("AVX2 + pthreads", "raw_hog_avx2-pthreads_2019-12-10--16-09-36.txt"),
	list("AVX2 + TBB", "raw_hog_avx2-tbb_2019-12-10--16-10-19.txt"),
	list("AVX2 + IPP + OpenMP", "raw_hog_avx2-ipp-openmp_2019-12-10--16-11-05.txt"),
	list("AVX2 + IPP + pthreads", "raw_hog_avx2-ipp-pthreads_2019-12-10--16-10-42.txt"),
	list("AVX2 + IPP + TBB", "raw_hog_avx2-ipp-tbb_2019-12-10--16-11-29.txt"))

setwd(LOGS_DIR)
results_summary <- data.frame()
for (res in results) {
	results_summary <- bind_rows(results_summary, read_results(group_col = "image_filename",
		optimization_group = res[[1]], optimization_num = 1, filename = res[[2]]))
}

charts <- list(
	list(list("AVX2", "AVX2 + IPP"),
		"HOG with AVX2 and IPP", "hog_avx2+ipp.pdf"),
	list(list("OpenMP", "pthreads", "TBB"),
		"HOG with parallel frameworks", "hog_parallel-frameworks.pdf"),
	list(list("AVX2 + OpenMP", "AVX2 + pthreads", "AVX2 + TBB"),
		"HOG with parallel frameworks and AVX2", "hog_avx2+parallel-frameworks.pdf"),
	list(list("AVX2 + IPP + OpenMP", "AVX2 + IPP + pthreads", "AVX2 + IPP + TBB"),
		"HOG with parallel frameworks, AVX2 and IPP", "hog_avx2+ipp+parallel-frameworks.pdf"))

setwd(PLOTS_DIR)
for (chart in charts) {
	chart_data <- results_summary %>% filter(optimization %in% chart[[1]])
	chart_data$image_filename <- factor(chart_data$image_filename, levels = sort(unique(chart_data$image_filename)))
	chart_data$optimization <- factor(chart_data$optimization, levels = sort(unique(chart_data$optimization)))
	build_plot_single(chart_data = chart_data, chart_title = chart[[2]], filename = chart[[3]])
}

groups <- list(
	list("people.jpg", "HOG", "hog.pdf"))

for (grp in groups) {
	chart_data <- results_summary %>% filter(image_filename == grp[[1]])
	chart_data$optimization <- factor(chart_data$optimization, levels = X_ORDER_ALL)
	build_plot_all(chart_data = chart_data, chart_title = grp[[2]], filename = grp[[3]])
}
