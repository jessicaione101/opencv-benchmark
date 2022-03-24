source("plot.r")

results <- list(
	list("No optimization", "raw_warpPerspective_no-optimization_2019-12-10--15-44-12.txt"),
	list("AVX2", "raw_warpPerspective_avx2_2019-12-10--15-45-01.txt"),
	list("AVX2 + IPP", "raw_warpPerspective_avx2-ipp_2019-12-10--15-45-22.txt"),
	list("OpenMP", "raw_warpPerspective_openmp_2019-12-10--15-44-31.txt"),
	list("pthreads", "raw_warpPerspective_pthreads_2019-12-10--15-44-21.txt"),
	list("TBB", "raw_warpPerspective_tbb_2019-12-10--15-44-40.txt"),
	list("AVX2 + OpenMP", "raw_warpPerspective_avx2-openmp_2019-12-10--15-45-38.txt"),
	list("AVX2 + pthreads", "raw_warpPerspective_avx2-pthreads_2019-12-10--15-45-30.txt"),
	list("AVX2 + TBB", "raw_warpPerspective_avx2-tbb_2019-12-10--15-45-45.txt"),
	list("AVX2 + IPP + OpenMP", "raw_warpPerspective_avx2-ipp-openmp_2019-12-10--15-46-04.txt"),
	list("AVX2 + IPP + pthreads", "raw_warpPerspective_avx2-ipp-pthreads_2019-12-10--15-45-55.txt"),
	list("AVX2 + IPP + TBB", "raw_warpPerspective_avx2-ipp-tbb_2019-12-10--15-46-13.txt"))

setwd(LOGS_DIR)
results_summary <- data.frame()
for (res in results) {
	results_summary <- bind_rows(results_summary, read_results(group_col = "dsize",
		optimization_group = res[[1]], optimization_num = 3, res[[2]]))
}

charts <- list(
	list(list("AVX2", "AVX2 + IPP"),
		"warpPerspective with AVX2 and IPP", "warpPerspective_avx2+ipp.pdf"),
	list(list("OpenMP", "pthreads", "TBB"),
		"warpPerspective with parallel frameworks", "warpPerspective_parallel-frameworks.pdf"),
	list(list("AVX2 + OpenMP", "AVX2 + pthreads", "AVX2 + TBB"),
		"warpPerspective with parallel frameworks and AVX2", "warpPerspective_avx2+parallel-frameworks.pdf"),
	list(list("AVX2 + IPP + OpenMP", "AVX2 + IPP + pthreads", "AVX2 + IPP + TBB"),
		"warpPerspective with parallel frameworks, AVX2 and IPP", "warpPerspective_avx2+ipp+parallel-frameworks.pdf"))
x_labels <- c("[640 x 480]" = "640x480 px","[1280 x 720]" = "1280x720 px", "[1920 x 1080]" = "1920x1080 px")
x_order <- c("[1920 x 1080]", "[1280 x 720]", "[640 x 480]")

setwd(PLOTS_DIR)
for (chart in charts) {
	chart_data <- results_summary %>% filter(optimization %in% chart[[1]])
	chart_data$dsize <- factor(chart_data$dsize, levels = x_order)
	chart_data$optimization <- factor(chart_data$optimization, levels = sort(unique(chart_data$optimization)))
	build_plot_group(chart_data = chart_data, chart_title = chart[[2]], x_col = "dsize",
		x_labels = x_labels, filename = chart[[3]])
}

groups <- list(
	list("[1920 x 1080]", "warpPerspective with 1920x1080 px", "warpPerspective_1920x1080.pdf"),
	list("[1280 x 720]", "warpPerspective with 1280x720 px", "warpPerspective_1280x720.pdf"),
	list("[640 x 480]", "warpPerspective with 640x480 px", "warpPerspective_640x480.pdf"))

for (grp in groups) {
	chart_data <- results_summary %>% filter(dsize == grp[[1]])
	chart_data$optimization <- factor(chart_data$optimization, levels = X_ORDER_ALL)
	build_plot_all(chart_data = chart_data, chart_title = grp[[2]], filename = grp[[3]])
}
