#!/bin/bash

WORKING_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)

BUILD_VERSION=(
  no-optimization
  pthreads
  openmp
  tbb
  avx2
  avx2-ipp
  avx2-pthreads
  avx2-openmp
  avx2-tbb
  avx2-ipp-pthreads
  avx2-ipp-openmp
  avx2-ipp-tbb
)

for build in ${BUILD_VERSION[@]}; do
  cd "${WORKING_DIR}"
  ./run-cmake.sh $build
  cd "${WORKING_DIR}/setup/$build/build"
  make -j 8
  make install
done
