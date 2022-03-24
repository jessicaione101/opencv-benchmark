#!/bin/bash

INTEL_ICC_DIR="/opt/intel/bin"

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

if [ "${build_version}" != "no-optimization" ]   &&
   [ "${build_version}" != "pthreads" ]          &&
   [ "${build_version}" != "openmp" ]            &&
   [ "${build_version}" != "tbb" ]               &&
   [ "${build_version}" != "avx2" ]              &&
   [ "${build_version}" != "avx2-ipp" ]          &&
   [ "${build_version}" != "avx2-pthreads" ]     &&
   [ "${build_version}" != "avx2-openmp" ]       &&
   [ "${build_version}" != "avx2-tbb" ]          &&
   [ "${build_version}" != "avx2-ipp-pthreads" ] &&
   [ "${build_version}" != "avx2-ipp-openmp" ]   &&
   [ "${build_version}" != "avx2-ipp-tbb" ]
then
  echo "${ERROR_MSG}"
  exit 1
fi

build_version_base_dir="${1}"

WORKING_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)
build_version_base_dir="${WORKING_DIR}/setup/${build_version}"

INSTALL_DIR="${build_version_base_dir}/install"
BUILD_DIR="${build_version_base_dir}/build"

source "${build_version_base_dir}/${build_version}.conf"

BUILD_CONFIG=(
  -D CMAKE_CXX_COMPILER="${INTEL_ICC_DIR}/icpc"
  -D CMAKE_C_COMPILER="${INTEL_ICC_DIR}/icc"
  -D CMAKE_Fortran_COMPILER="${INTEL_ICC_DIR}/ifort"
  -D CMAKE_INSTALL_PREFIX="${INSTALL_DIR}"
  -D BUILD_SHARED_LIBS=OFF
  -D CMAKE_BUILD_TYPE=Release
  -D WITH_LAPACK=OFF
)

TEST_CONFIG=(
  -D BUILD_PERF_TESTS=ON
  -D BUILD_TESTS=OFF
  -D BUILD_opencv_python_tests=OFF
  -D INSTALL_TESTS=OFF
)

MODULE_CONFIG=(
  -D OPENCV_ENABLE_NONFREE=ON
  -D BUILD_opencv_core=ON
  -D BUILD_opencv_imgproc=ON
  -D BUILD_opencv_video=ON
  -D BUILD_opencv_calib3d=ON
  -D BUILD_opencv_features2d=ON
  -D BUILD_opencv_objdetect=ON
  -D BUILD_opencv_dnn=ON
  -D BUILD_opencv_ml=ON
  -D BUILD_opencv_flann=ON
  -D BUILD_opencv_photo=ON
)

rm -rf "${BUILD_DIR}"
rm -rf "${INSTALL_DIR}"
mkdir "${BUILD_DIR}"
mkdir "${INSTALL_DIR}"
cd "${BUILD_DIR}"

cmake \
  -G "Unix Makefiles" \
  ${BUILD_CONFIG[@]} \
  ${OPTMIZATION_CONFIG[@]} \
  ${MODULE_CONFIG[@]} \
  ${TEST_CONFIG[@]} \
  ../../../opencv-4.1.2 \
  | tee "${build_version_base_dir}/cmake-output.txt"
