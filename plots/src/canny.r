source("plot.r")

results <- list(
	list("No optimization", "raw_canny_no-optimization_2019-12-10--15-35-12.txt"),
	list("AVX2", "raw_canny_avx2_2019-12-10--15-36-40.txt"),
	list("AVX2 + IPP", "raw_canny_avx2-ipp_2019-12-10--15-37-17.txt"),
	list("OpenMP", "raw_canny_openmp_2019-12-10--15-35-40.txt"),
	list("pthreads", "raw_canny_pthreads_2019-12-10--15-35-26.txt"),
	list("TBB", "raw_canny_tbb_2019-12-10--15-35-54.txt"),
	list("AVX2 + OpenMP", "raw_canny_avx2-openmp_2019-12-10--15-37-42.txt"),
	list("AVX2 + pthreads", "raw_canny_avx2-pthreads_2019-12-10--15-37-30.txt"),
	list("AVX2 + TBB", "raw_canny_avx2-tbb_2019-12-10--15-37-55.txt"),
	list("AVX2 + IPP + OpenMP", "raw_canny_avx2-ipp-openmp_2019-12-10--15-38-26.txt"),
	list("AVX2 + IPP + pthreads", "raw_canny_avx2-ipp-pthreads_2019-12-10--15-38-11.txt"),
	list("AVX2 + IPP + TBB", "raw_canny_avx2-ipp-tbb_2019-12-10--15-38-42.txt"))

setwd(LOGS_DIR)
results_summary <- data.frame()
for (res in results) {
	results_summary <- bind_rows(results_summary, read_results(group_col = "image_filename",
		optimization_group = res[[1]], optimization_num = 3, filename = res[[2]]))
}

charts <- list(
	list(list("AVX2", "AVX2 + IPP"),
		"Canny with AVX2 and IPP", "canny_avx2+ipp.pdf"),
	list(list("OpenMP", "pthreads", "TBB"),
		"Canny with parallel frameworks", "canny_parallel-frameworks.pdf"),
	list(list("AVX2 + OpenMP", "AVX2 + pthreads", "AVX2 + TBB"),
		"Canny with parallel frameworks and AVX2", "canny_avx2+parallel-frameworks.pdf"),
	list(list("AVX2 + IPP + OpenMP", "AVX2 + IPP + pthreads", "AVX2 + IPP + TBB"),
		"Canny with parallel frameworks, AVX2 and IPP", "canny_avx2+ipp+parallel-frameworks.pdf"))
x_labels = c("baboon.jpg" = "baboon","beads.jpg" = "beads", "lena.jpg" = "lena")
x_order <- c("beads.jpg", "baboon.jpg", "lena.jpg")

setwd(PLOTS_DIR)
for (chart in charts) {
	chart_data <- results_summary %>% filter(optimization %in% chart[[1]])
	chart_data$image_filename <- factor(chart_data$image_filename, levels = x_order)
	chart_data$optimization <- factor(chart_data$optimization, levels = sort(unique(chart_data$optimization)))
	build_plot_group(chart_data = chart_data, chart_title = chart[[2]], x_col = "image_filename",
		x_labels = x_labels, filename = chart[[3]])
}

groups <- list(
	list("baboon.jpg", "Canny with baboon", "canny_baboon.pdf"),
	list("beads.jpg", "Canny with beads", "canny_beads.pdf"),
	list("lena.jpg", "Canny with lena", "canny_lena.pdf"))

for (grp in groups) {
	chart_data <- results_summary %>% filter(image_filename == grp[[1]])
	chart_data$optimization <- factor(chart_data$optimization, levels = X_ORDER_ALL)
	build_plot_all(chart_data = chart_data, chart_title = grp[[2]], filename = grp[[3]])
}
