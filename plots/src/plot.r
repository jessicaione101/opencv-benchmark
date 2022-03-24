LOGS_DIR <- "../../tests/logs/"
PLOTS_DIR <- "../"
TEXT_SIZE <- 22

X_ORDER_ALL <- c(
	"No optimization", "AVX2", "AVX2 + IPP",
	"OpenMP", "AVX2 + OpenMP", "AVX2 + IPP + OpenMP",
	"pthreads", "AVX2 + pthreads", "AVX2 + IPP + pthreads",
	"TBB", "AVX2 + TBB", "AVX2 + IPP + TBB")

library(dplyr)

read_results <- function(group_col, optimization_group, optimization_num, filename) {
	results_table <- read.table(filename, sep = "\t", header = TRUE)
	results_table <- results_table %>% group_by_(group_col) %>%
		summarise(mean_sec = mean(runtime_sec))
	results_table$optimization <- rep(c(optimization_group), optimization_num)
	results_table
}

library(ggplot2)

build_plot_group <- function(chart_data, x_col, x_labels, chart_title, filename) {
	plot <- ggplot(data = chart_data, aes_(x = as.name(x_col), y = as.name("mean_sec"), fill = as.name("optimization"))) +
		geom_col(position = position_dodge()) +
		scale_x_discrete(labels = x_labels) +
		theme_bw() +
		theme(
			text = element_text(size = TEXT_SIZE),
			legend.title = element_blank(),
			legend.text.align = 0,
			panel.grid.major = element_line("gray", size = 0.5, linetype = "dashed"),
			legend.text = element_text(size = TEXT_SIZE-2),
			legend.position = c(0.8, 0.8),
			axis.title.x = element_blank(),
			legend.key.size = unit(1, "cm"),
			plot.title = element_text(hjust = 0.5)) +
		labs(title = chart_title, y = "Execution time (s)")
	ggsave(filename, width = 12, height = 8.5, plot = plot, device = cairo_pdf)
}

build_plot_all <- function(chart_data, chart_title, filename) {
	plot <- ggplot(data = chart_data, aes(x = optimization, y = mean_sec, fill = optimization)) +
		geom_col(show.legend = FALSE) +
		theme_bw() +
		theme(
			text = element_text(size = TEXT_SIZE),
			axis.text.x = element_text(angle = 45, hjust = 1),
			panel.grid.major = element_line("gray", size = 0.5, linetype = "dashed"),
			axis.title.x = element_blank(),
			plot.title = element_text(hjust = 0.5)) +
		labs(title = chart_title, y = "Execution time (s)")
	ggsave(filename, width = 15, height = 8.5, plot = plot, device = cairo_pdf)
}

build_plot_single <- function(chart_data, chart_title, filename) {
	plot <- ggplot(data = chart_data, aes(x = optimization, y = mean_sec, fill = optimization)) +
		geom_col(show.legend = FALSE, width = 0.5) +
		theme_bw() +
		theme(
			text = element_text(size = TEXT_SIZE),
			panel.grid.major = element_line("gray", size = 0.5, linetype = "dashed"),
			axis.title.x = element_blank(),
			plot.title = element_text(hjust = 0.5)) +
		labs(title = chart_title, y = "Execution time (s)")
	ggsave(filename, width = 12, height = 8.5, plot = plot, device = cairo_pdf)
}
