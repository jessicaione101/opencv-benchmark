#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <chrono>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/objdetect.hpp>
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
  const std::string image_filename("./data/people.jpg");
  std::vector<cv::Rect> foundLocations;
  cv::HOGDescriptor hog;

  const cv::Mat img = cv::imread(image_filename, cv::IMREAD_GRAYSCALE);
  if (img.empty()) {
    std::cerr << "Unable to load source image " << image_filename << std::endl;
    return 1;
  }

  std::string filename = image_filename.substr(image_filename.rfind('/')+1);
  std::ofstream raw_output(rawOutputFilename);
  std::chrono::high_resolution_clock::time_point begin, end;
  std::chrono::duration<double> time_elapsed;
  std::vector<double> time_samples(numSamples);

  raw_output << "image_filename" << separator
    << "image_size" << separator
    << "classifier" << separator
    << "coefficients" << separator
    << "sample_num" << separator
    << "runtime_sec" << std::endl;

  std::cout << "image_filename" << separator
    << "image_size" << separator
    << "classifier" << separator
    << "coefficients" << separator
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

  hog.setSVMDetector(hog.getDefaultPeopleDetector());

  for (int s = 0; s < numSamples; ++s) {
    begin = std::chrono::high_resolution_clock::now();
    hog.detectMultiScale(img, foundLocations);
    end = std::chrono::high_resolution_clock::now();
    time_elapsed = std::chrono::duration_cast<std::chrono::duration<double>>(end - begin);
    time_samples[s] = time_elapsed.count();
    
    raw_output << filename << separator
      << img.size() << separator
      << "svm" << separator
      << "default_people_detector" << separator
      << s+1 << separator
      << time_samples[s] << std::endl;
  }

  std::cout << filename << separator
    << img.size() << separator
    << "svm" << separator
    << "default_people_detector" << separator
    << numSamples << separator
    << min(time_samples) << separator
    << max(time_samples) << separator
    << median(time_samples) << separator
    << gmean(time_samples) << separator
    << mean(time_samples) << separator
    << stddev(time_samples) << std::endl;

  raw_output.close();

  return 0;
}
