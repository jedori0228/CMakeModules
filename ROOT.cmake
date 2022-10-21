include(CMessage)

if(NOT DEFINED ROOT_FOUND)
  find_package(ROOT)
  if(DEFINED ROOT_USE_FILE AND NOT "${ROOT_USE_FILE}x" STREQUAL "x")
    include(${ROOT_USE_FILE})
  endif()
endif()

string(FIND "${CMAKE_SHARED_LINKER_FLAGS}" "-Wl,--no-undefined" NOUNDEF_INDEX)
if(NOUNDEF_INDEX GREATER -1)
  string(REPLACE "-Wl,--no-undefined" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
  cmessage(STATUS "Removed -Wl,--no-undefined flag from CMAKE_SHARED_LINKER_FLAGS that ROOT tried to add.")
endif()

if(NOT TARGET ROOT::ROOT)
  if(NOT DEFINED ROOT_CXX_FLAGS AND DEFINED ROOT_DEFINITIONS)
    SET(ROOT_CXX_FLAGS ${ROOT_DEFINITIONS})
  endif()

  STRING(STRIP "${ROOT_CXX_FLAGS}" ROOT_CXX_FLAGS)
  STRING(REPLACE " " ";" ROOT_CXX_FLAGS ${ROOT_CXX_FLAGS})

  list (FIND ROOT_CXX_FLAGS "-std=c++11" CPP11_INDEX)
  list (FIND ROOT_CXX_FLAGS "-std=c++1x" CPP1X_INDEX)
  list (FIND ROOT_CXX_FLAGS "-std=c++14" CPP14_INDEX)
  list (FIND ROOT_CXX_FLAGS "-std=c++1y" CPP1Y_INDEX)
  list (FIND ROOT_CXX_FLAGS "-std=c++17" CPP17_INDEX)
  list (FIND ROOT_CXX_FLAGS "-std=c++1z" CPP1Z_INDEX)
  list (FIND ROOT_CXX_FLAGS "-std=c++20" CPP20_INDEX)

  if (${CPP11_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 11)
  elseif (${CPP1X_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 11)
  elseif (${CPP14_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 14)
  elseif (${CPP1Y_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 14)
  elseif (${CPP17_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 17)
  elseif (${CPP1Z_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 17)
  elseif (${CPP20_INDEX} GREATER -1)
    SET(ROOT_CXX_STANDARD 20)
  else()
    SET(ROOT_CXX_STANDARD 11)
  endif()


  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++11")
  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++1x")
  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++14")
  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++1y")
  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++17")
  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++1z")
  list (REMOVE_ITEM ROOT_CXX_FLAGS "-std=c++20")
  #We should let CMake set this
  list(REMOVE_ITEM ROOT_CXX_FLAGS "-fPIC")

  execute_process (COMMAND root-config
    --version OUTPUT_VARIABLE ROOT_CONFIG_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)

  add_library(ROOT::ROOT INTERFACE IMPORTED GLOBAL)

  LIST(APPEND ROOT_LIB_NAMES Core)

  if(ROOT_VERSION VERSION_LESS 6.0.0)
    LIST(APPEND ROOT_LIB_NAMES Cint)
  endif()

  LIST(APPEND ROOT_LIB_NAMES 
    Core
    RIO
    XMLIO
    Net
    Hist
    Graf
    Graf3d
    Gpad
    Tree
    Rint
    Postscript
    Matrix
    Physics
    MathMore
    MathCore
    Thread
    EG
    Geom
    GenVector)

  foreach(LN ${ROOT_LIB_NAMES})
    if(NOT EXISTS ${ROOT_LIBRARY_DIR}/lib${LN}.so)
      cmessage(FATAL_ERROR "Cannot find ROOT library: ${LN} in expected directory: ${ROOT_LIBRARY_DIR}")
    endif()
  endforeach()

  # Get features from ROOT
  execute_process (COMMAND root-config
    --features OUTPUT_VARIABLE ROOT_FEATURES OUTPUT_STRIP_TRAILING_WHITESPACE)
  if("${ROOT_FEATURES}" MATCHES "minuit2")
    cmessage(STATUS "ROOT built with MINUIT2 support")
    SET(MINIMIZER_ENABLED TRUE)
    LIST(APPEND ROOT_CXX_FLAGS -DMINUIT2_ENABLED)
    if(ROOT_VERSION VERSION_GREATER 6.0.0)
      LIST(APPEND ROOT_CXX_FLAGS -DROOT_FIT_FITTER_INTERFACE_ENABLED)
    endif()
  else()
    SET(MINIMIZER_ENABLED FALSE)
  endif()

  foreach(flag ${ROOT_CXX_FLAGS})
    list(APPEND ROOT_COMPILE_FLAGS "$<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:${flag}>")
  endforeach()

  set_target_properties(ROOT::ROOT PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${ROOT_INCLUDE_DIRS}"
      INTERFACE_COMPILE_OPTIONS "${ROOT_COMPILE_FLAGS}"
      INTERFACE_LINK_DIRECTORIES "${ROOT_LIBRARY_DIR}"
      INTERFACE_LINK_LIBRARIES "${ROOT_LIB_NAMES}"
  )
  
  cmessage(STATUS "Built ROOT::ROOT Imported target")
  cmessage(STATUS "        ROOT_CXX_STANDARD: ${ROOT_CXX_STANDARD}")
  cmessage(STATUS "        ROOT_INCLUDE_DIRS: ${ROOT_INCLUDE_DIRS}")
  cmessage(STATUS "        ROOT_CXX_FLAGS: ${ROOT_CXX_FLAGS}")
  cmessage(STATUS "        ROOT_COMPILE_FLAGS: ${ROOT_COMPILE_FLAGS}")
  cmessage(STATUS "        ROOT_LIBRARIES: ${ROOT_LIBRARIES}")
  cmessage(STATUS "        ROOT_CONFIG_VERSION: ${ROOT_CONFIG_VERSION}")
endif()
