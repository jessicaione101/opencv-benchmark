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

cd "${WORKING_DIR}"

for build in ${BUILD_VERSION[@]}; do
  ./run-tests.sh $build
done
