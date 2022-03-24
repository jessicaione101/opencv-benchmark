#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>
#include <chrono>
#include <opencv2/imgproc.hpp>
#include "warp.hpp"
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

cv::Mat buildWarpMatrix(const cv::Mat& src, const cv::Size& dst_size);

int main() {
  const cv::Size src_size(512, 512);
  const cv::Scalar borderValue = cv::Scalar::all(150);
  const std::vector<cv::Size> dsize{cv::Size(640, 480), cv::Size(1280, 720), cv::Size(1920, 1080)};
  const std::vector<int> flags{cv::INTER_LINEAR, cv::INTER_NEAREST};
  const std::vector<int> borderMode{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE};

  std::map<int, std::string> flags_str;
  flags_str[cv::INTER_LINEAR] = "INTER_LINEAR";
  flags_str[cv::INTER_NEAREST] = "INTER_NEAREST";
  std::map<int, std::string> borderMode_str;
  borderMode_str[cv::BORDER_CONSTANT] = "BORDER_CONSTANT";
  borderMode_str[cv::BORDER_REPLICATE] = "BORDER_REPLICATE";

  std::ofstream raw_output(rawOutputFilename);
  std::chrono::high_resolution_clock::time_point begin, end;
  std::chrono::duration<double> time_elapsed;
  std::vector<double> time_samples(numSamples);

  raw_output << "dsize" << separator
    << "flags" << separator
    << "borderMode" << separator
    << "sample_num" << separator
    << "runtime_sec" << std::endl;

  std::cout << "dsize" << separator
    << "flags" << separator
    << "borderMode" << separator
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

  cv::Mat src(src_size, CV_8UC4);

  for (int i = 0; i < dsize.size(); ++i) {
    cv::Mat dst(dsize[i], CV_8UC4);
    cv::Mat M = buildWarpMatrix(src, dsize[i]);
    for (int j = 0; j < flags.size(); ++j) {
      for (int k = 0; k < borderMode.size(); ++k) {
        fillGradient(src);
        if (borderMode[k] == cv::BORDER_CONSTANT)
          smoothBorder(src, borderValue, 1);

        for (int s = 0; s < numSamples; ++s) {
          begin = std::chrono::high_resolution_clock::now();
          cv::warpPerspective(src, dst, M, dsize[i], flags[j], borderMode[k], borderValue);
          end = std::chrono::high_resolution_clock::now();
          time_elapsed = std::chrono::duration_cast<std::chrono::duration<double>>(end - begin);
          time_samples[s] = time_elapsed.count();

          raw_output << dsize[i] << separator
            << flags_str[flags[j]] << separator
            << borderMode_str[borderMode[k]] << separator
            << s+1 << separator
            << time_samples[s] << std::endl;
        }

        std::cout << dsize[i] << separator
          << flags_str[flags[j]] << separator
          << borderMode_str[borderMode[k]] << separator
          << numSamples << separator
          << min(time_samples) << separator
          << max(time_samples) << separator
          << median(time_samples) << separator
          << gmean(time_samples) << separator
          << mean(time_samples) << separator
          << stddev(time_samples) << std::endl;

        src = cv::Mat(src_size, CV_8UC4);
      }
    }
  }

  raw_output.close();

  return 0;
}

cv::Mat buildWarpMatrix(const cv::Mat& src, const cv::Size& dst_size) {
  cv::Mat rotation = cv::getRotationMatrix2D(cv::Point2f(src.cols/2.f, src.rows/2.f), 30., 2.2);
  cv::Mat warp(3, 3, CV_64FC1);

  for(int r = 0; r < 2; ++r)
    for(int c = 0; c < 3; ++c)
      warp.at<double>(r, c) = rotation.at<double>(r, c);

  warp.at<double>(2, 0) = .3/dst_size.width;
  warp.at<double>(2, 1) = .3/dst_size.height;
  warp.at<double>(2, 2) = 1;

  return std::move(warp);
}
