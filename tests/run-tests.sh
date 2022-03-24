#!/bin/bash

ERROR_MSG="Run with one option: \
  no-optimization \
  pthreads \
  openmp \
  tbb \
  avx2 \
  avx2-ipp \
  avx2-pthreads \
  avx2-openmp \
  avx2-tbb \
  avx2-ipp-pthreads \
  avx2-ipp-openmp \
  avx2-ipp-tbb"

if [ "${#}" -ne 1 ]; then
  echo "${ERROR_MSG}"
  exit 1
fi

build_version="${1}"
raw_output_filename="./logs/${build_version}_raw_output_temp.txt"
runtime_conf="const char rawOutputFilename[] = \"${raw_output_filename}\";"

if [ "${build_version}" = "no-optimization" ] ||
   [ "${build_version}" = "avx2" ]            ||
   [ "${build_version}" = "avx2-ipp" ]
then
  runtime_conf="${runtime_conf}"
elif [ "${build_version}" = "pthreads" ]          ||
     [ "${build_version}" = "tbb" ]               ||
     [ "${build_version}" = "avx2-pthreads" ]     ||
     [ "${build_version}" = "avx2-tbb" ]          ||
     [ "${build_version}" = "avx2-ipp-pthreads" ] ||
     [ "${build_version}" = "avx2-ipp-tbb" ]
then
  runtime_conf="#define PARALLEL\\n\\n${runtime_conf}"
elif [ "${build_version}" = "openmp" ]      ||
     [ "${build_version}" = "avx2-openmp" ] ||
     [ "${build_version}" = "avx2-ipp-openmp" ]
then
  runtime_conf="#define PARALLEL\\n#define OPENMP\\n\\n${runtime_conf}"
else
  echo "${ERROR_MSG}"
  exit 1
fi

WORKING_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)

cd "${WORKING_DIR}"
cd ..
OPENCV_INSTALL_DIR="$(pwd)/setup/${build_version}/install"

OPENCV_INCLUDE_DIR="${OPENCV_INSTALL_DIR}/include/opencv4"
OPENCV_LIBS_DIR="${OPENCV_INSTALL_DIR}/lib/"
CXX=/opt/intel/bin/icpc
CXXFLAGS="-std=c++14"
LIBS="-lpng -lz -lpthread -fopenmp"
OPENCV_LIBS="$(for x in $(find "${OPENCV_LIBS_DIR}" -type f -name *.a); do echo -n "$x "; done)"

cd "${WORKING_DIR}"
echo -e "${runtime_conf}" > runtime_conf.hpp

function compile_and_run {
  echo "--- ${1} with ${2}"

  echo "Compiling..."
  ${CXX} ${1}.cpp -o ${1} ${CXXFLAGS} -I ${OPENCV_INCLUDE_DIR} -Wl,--start-group ${OPENCV_LIBS} ${LIBS} -Wl,--end-group

  temp_filename="./logs/${1}_${2}_temp.txt"
  echo "Running..."
  sudo chrt -f 99 ./${1} | tee "${temp_filename}"

  time_stamp="$(date "+%F--%H-%M-%S")"
  mv "${temp_filename}" "./logs/${1}_${2}_${time_stamp}.txt"
  mv "${raw_output_filename}" "./logs/raw_${1}_${2}_${time_stamp}.txt"

  rm -f ${1}
  rm -f runtime_conf.hpp
}

#compile_and_run canny ${1}
#compile_and_run warpPerspective ${1}
#compile_and_run hog ${1}
