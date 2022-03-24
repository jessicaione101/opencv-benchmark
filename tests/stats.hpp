#include <functional>
#include <numeric>
#include <algorithm>
#include <cmath>

double min(const std::vector<double>& samples) {
  return *std::min_element(samples.begin(), samples.end());
}

double max(const std::vector<double>& samples) {
  return *std::max_element(samples.begin(), samples.end());
}

double median(const std::vector<double>& samples) {
  std::vector<double> samples_copy(samples);
  std::sort(samples_copy.begin(), samples_copy.end());

  int num_samples = samples_copy.size();
  if (num_samples % 2 == 1)
    return samples_copy[(num_samples-1)/2];
  return (samples_copy[num_samples/2] + samples_copy[num_samples/2 - 1]) / 2.0;
}

double gmean(const std::vector<double>& samples) {
  return std::pow(std::accumulate(samples.begin(), samples.end(), double(1), std::multiplies<double>()),
                  1.0/samples.size());
}

double mean(const std::vector<double>& samples) {
  return std::accumulate(samples.begin(), samples.end(), double(0))
         / samples.size();
}

double stddev(const std::vector<double>& samples) {
  double mean_value = mean(samples);
  std::vector<double> samples_copy(samples);

  std::for_each(samples_copy.begin(), samples_copy.end(),
    [&](double &s){s = std::pow(s-mean_value, 2);});

  return std::sqrt(std::accumulate(samples_copy.begin(), samples_copy.end(), double(0))
         / (samples.size()-1));
}
