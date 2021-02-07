// Copyright (c) 2021 Jisang Yoon
// All rights reserved.
//
// This source code is licensed under the Apache 2.0 license found in the
// LICENSE file in the root directory of this source tree.
#pragma once
#include <thrust/copy.h>
#include <thrust/fill.h>
#include <thrust/random.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/binary_search.h>
#include <thrust/execution_policy.h>

#include <omp.h>
#include <set>
#include <random>
#include <memory>
#include <string>
#include <fstream>
#include <utility>
#include <queue>
#include <deque>
#include <functional>
#include <vector>
#include <cmath>
#include <chrono> // NOLINT

#include "json11.hpp"
#include "utils/log.hpp"
#include "utils/types.hpp"

#define DEBUG1(x) LOGGER->debug("[{}:{}] " x "\n", __FILENAME__, __LINE__);

namespace cusim {

std::shared_ptr<spdlog::logger> LOGGER = CuSimLogger().get_logger();

struct DeviceInfo {
  int devId, mp_cnt, major, minor, cores;
}

DeviceInfo GetDeviceInfo() {
  DeviceInfo ret;
  CHECK_CUDA(cudaGetDevice(&ret.devId));
  cudaDeviceProp prop;
  CHECK_CUDA(cudaGetDeviceProperties(&prop, ret.devId));
  ret.mp_cnt = prop.multiProcessorCount;
  ret.major = prop.major;
  ret.minor = prop.minor;
  // reference: https://stackoverflow.com/a/32531982
  switch (ret.major) {
    case 2: // Fermi
      if (ret.minor == 1)
        ret.cores = ret.mp_cnt * 48;
      else
        ret.cores = ret.mp_cnt * 32;
      break;
    case 3: // Kepler
      ret.cores = ret.mp_cnt * 192;
      break;
    case 5: // Maxwell
      ret.cores = ret.mp_cnt * 128;
      break;
    case 6: // Pascal
      if (ret.minor == 1 or ret.minor == 2)
        ret.cores = ret.mp_cnt * 128;
      else if (ret.minor == 0)
        ret.cores = ret.mp_cnt * 64;
      else
        DEBUG1("Unknown device type");
      break;
    case 7: // Volta and Turing
      if (ret.minor == 0 or ret.minor == 5)
        ret.cores = ret.mp_cnt * 64;
      else
        DEBUG1("Unknown device type");
      break;
    case 8: // Ampere
      if (ret.minor == 0)
        ret.cores = ret.mp_cnt * 64;
      else if (minor_ == 6)
        ret.cores = ret.mp_cnt * 128;
      else
        DEBUG1("Unknown device type");
      break;
    default:
      DEBUG1("Unknown device type");
      break;
  }
  if (ret.cores == -1) ret.cores = ret.mp_cnt * 128;
  return ret
}


} // namespace cusim
