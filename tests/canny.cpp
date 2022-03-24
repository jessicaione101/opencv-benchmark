#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <tuple>
#include <chrono>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include "stats.hpp"
#include "test_conf.hpp"
#include "runtime_conf.hpp"
#include "hardware_conf.hpp"
#ifdef OPENMP
  #include <omp.h>
#endif

extern const int numCores;
extern const int numSamples;
extern const char rawOutputFilename[];
const char separator = '\t';

int main() {
  const std::vector<std::string> image_filename{"./data/baboon.jpg", "./data/beads.jpg", "./data/lena.jpg"};
  const std::vector<std::tuple<double, double>> thresholds
    {std::make_tuple(50.0, 100.0), std::make_tuple(0.0, 50.0), std::make_tuple(100.0, 120.0)};
  const std::vector<int> apertureSize{3, 5};

  double threshold1, threshold2;
  std::string filename;
  std::ofstream raw_output(rawOutputFilename);
  std::chrono::high_resolution_clock::time_point begin, end;
  std::chrono::duration<double> time_elapsed;
  std::vector<double> time_samples(numSamples);

  raw_output << "image_filename" << separator
    << "image_size" << separator
    << "threshold1" << separator
    << "threshold2" << separator
    << "apertureSize" << separator
    << "L2gradient" << separator
    << "sample_num" << separator
    << "runtime_sec" << std::endl;

  std::cout << "image_filename" << separator
    << "image_size" << separator
    << "threshold1" << separator
    << "threshold2" << separator
    << "apertureSize" << separator
    << "L2gradient" << separator
    << "samples" << separator
    << "min_sec" << separator
    << "max_sec" << separator
    << "median_sec" << separator
    << "gmean_sec" << separator
    << "mean_sec" << separator
    << "stddev_sec" << std::endl;

  int num_thread = 1;
  #ifdef PARALLEL
    num_thread = numCores;
  #endif
  cv::setNumThreads(num_thread);

  #ifdef OPENMP
    omp_set_dynamic(0);
    omp_set_num_threads(num_thread);
  #endif

  for (int i = 0; i < image_filename.size(); ++i) {
    cv::Mat img = cv::imread(image_filename[i], cv::IMREAD_GRAYSCALE);
    if (img.empty()) {
      std::cerr << "Unable to load source image " << image_filename[i] << std::endl;
      return 1;
    }
    cv::Mat edges(img.size(), img.type());

    filename = image_filename[i].substr(image_filename[i].rfind('/')+1);

    for (int j = 0; j < thresholds.size(); ++j) {
      threshold1 = std::get<0>(thresholds[j]);
      threshold2 = std::get<1>(thresholds[j]);

      for (int k = 0; k < apertureSize.size(); ++k) {

        for (int s = 0; s < numSamples; ++s) {
          begin = std::chrono::high_resolution_clock::now();
          cv::Canny(img, edges, threshold1, threshold2, apertureSize[k], true);
          end = std::chrono::high_resolution_clock::now();
          time_elapsed = std::chrono::duration_cast<std::chrono::duration<double>>(end - begin);
          time_samples[s] = time_elapsed.count();

          raw_output << filename << separator
            << img.size() << separator
            << threshold1 << separator
            << threshold2 << separator
            << apertureSize[k] << separator
            << "true" << separator
            << s+1 << separator
            << time_samples[s] << std::endl;
        }

        std::cout << filename << separator
          << img.size() << separator
          << threshold1 << separator
          << threshold2 << separator
          << apertureSize[k] << separator
          << "true" << separator
          << numSamples << separator
          << min(time_samples) << separator
          << max(time_samples) << separator
          << median(time_samples) << separator
          << gmean(time_samples) << separator
          << mean(time_samples) << separator
          << stddev(time_samples) << std::endl;

        for (int s = 0; s < numSamples; ++s) {
          begin = std::chrono::high_resolution_clock::now();
          cv::Canny(img, edges, threshold1, threshold2, apertureSize[k], false);
          end = std::chrono::high_resolution_clock::now();
          time_elapsed = std::chrono::duration_cast<std::chrono::duration<double>>(end - begin);
          time_samples[s] = time_elapsed.count();

          raw_output << filename << separator
            << img.size() << separator
            << threshold1 << separator
            << threshold2 << separator
            << apertureSize[k] << separator
            << "false" << separator
            << s+1 << separator
            << time_samples[s] << std::endl;
        }

        std::cout << filename << separator
          << img.size() << separator
          << threshold1 << separator
          << threshold2 << separator
          << apertureSize[k] << separator
          << "true" << separator
          << numSamples << separator
          << min(time_samples) << separator
          << max(time_samples) << separator
          << median(time_samples) << separator
          << gmean(time_samples) << separator
          << mean(time_samples) << separator
          << stddev(time_samples) << std::endl;

      }
    }
  }

  raw_output.close();

  return 0;
}
