################################################################################
# MIT License

# Copyright (c) 2022 NuHepMC/CMakeModules

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################

cmake_minimum_required (VERSION 3.14 FATAL_ERROR)

project(CMakeModules VERSION 0.2.4)

if(CMAKE_INSTALL_PREFIX STREQUAL "" OR CMAKE_INSTALL_PREFIX STREQUAL
  "/usr/local")
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_NAME}")
elseif(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_NAME}")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/NuHepMCModules.cmake)

install(FILES
  ${CMAKE_CURRENT_LIST_DIR}/CMessage.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindGENIE.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindGENIE2.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindGENIE3.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindGENIEDependencies.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindGENIEVersion.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindLHAPDF.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindNEUT53X.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindNEUT54X.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindNEUTConfigLegacy.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindNuWro.cmake
  ${CMAKE_CURRENT_LIST_DIR}/FindPythia6.cmake
  ${CMAKE_CURRENT_LIST_DIR}/Findlog4cpp.cmake
  ${CMAKE_CURRENT_LIST_DIR}/NEUT.cmake
  ${CMAKE_CURRENT_LIST_DIR}/NuHepMCModules.cmake
  ${CMAKE_CURRENT_LIST_DIR}/NuHepMCUtils.cmake
  ${CMAKE_CURRENT_LIST_DIR}/ParseConfigApps.cmake
  ${CMAKE_CURRENT_LIST_DIR}/ROOT.cmake
        DESTINATION cmake)