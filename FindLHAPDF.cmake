include(CMessage)

if(NOT TARGET LHAPDF::LHAPDF)
  EnsureVarOrEnvSet(LHAPDF_ENV_INC LHAPDF_INC)
  if("${LHAPDF_ENV_INC}" STREQUAL "LHAPDF_ENV_INC-NOTFOUND")
    find_program(LHAPDFCONFIG NAMES lhapdf-config)
    if("${LHAPDFCONFIG}" STREQUAL "LHAPDFCONFIG-NOTFOUND")
      cmessage(WARNING "Could not find lhapdf-config, but LHAPDF_INC is not set in the environment")
      SET(LHAPDF_FOUND FALSE)
      return()
    endif()

    execute_process (COMMAND lhapdf-config --incdir 
                      OUTPUT_VARIABLE LHAPDF_ENV_INC 
                      OUTPUT_STRIP_TRAILING_WHITESPACE)
    cmessage(STATUS "Used lhapdf-config to resolve LHAPDF_INC=${LHAPDF_ENV_INC}")
  endif()

  find_path(LHAPDF_INC
    NAMES LHAPDF/Config.h
          LHAPDF/LHAPDFConfig.h
    PATHS ${LHAPDF_ENV_INC})

  if("${LHAPDF_INC}" STREQUAL "LHAPDF_INC-NOTFOUND")
    cmessage(WARNING "When configuring GENIE with LHAPDF_INC=\"${LHAPDF_ENV_INC}\", failed find required file \"LHAPDF/config.h\".")
    SET(LHAPDF_FOUND FALSE)
    return()
  endif()

  EnsureVarOrEnvSet(LHAPDF_ENV_LIB LHAPDF_LIB)
  if("${LHAPDF_ENV_LIB}" STREQUAL "LHAPDF_ENV_LIB-NOTFOUND")
    find_program(LHAPDFCONFIG NAMES lhapdf-config)
    if("${LHAPDFCONFIG}" STREQUAL "LHAPDFCONFIG-NOTFOUND")
      cmessage(WARNING "Could not find lhapdf-config, but LHAPDF_LIB is not set in the environment")
      SET(LHAPDF_FOUND FALSE)
      return()
    endif()

    execute_process (COMMAND lhapdf-config --libdir 
                      OUTPUT_VARIABLE LHAPDF_ENV_LIB 
                      OUTPUT_STRIP_TRAILING_WHITESPACE)
    cmessage(STATUS "Used lhapdf-config to resolve LHAPDF_LIB=${LHAPDF_ENV_LIB}")
  endif()

  find_path(LHAPDF_LIB
    NAMES libLHAPDF.so
    PATHS ${LHAPDF_ENV_LIB})

  if("${LHAPDF_LIB}" STREQUAL "LHAPDF_LIB-NOTFOUND")
    cmessage(WARNING "When configuring GENIE with LHAPDF_LIB=\"${LHAPDF_ENV_LIB}\", failed find required file \"libLHAPDF.so\".")
    SET(LHAPDF_FOUND FALSE)
    return()
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(LHAPDF
      REQUIRED_VARS 
        LHAPDF_INC
        LHAPDF_LIB
  )

  if(NOT LHAPDF_FOUND)
    return()
  endif()

  cmessage(STATUS "Found LHAPDF:")
  cmessage(STATUS "     LHAPDF_INC: ${LHAPDF_INC}")
  cmessage(STATUS "     LHAPDF_LIB: ${LHAPDF_LIB}")

  add_library(LHAPDF::LHAPDF INTERFACE IMPORTED)
  set_target_properties(LHAPDF::LHAPDF PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${LHAPDF_INC}
      INTERFACE_LINK_DIRECTORIES ${LHAPDF_LIB}
      INTERFACE_LINK_LIBRARIES LHAPDF
    )

endif()
