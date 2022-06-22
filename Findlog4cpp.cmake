include(CMessage)
include(ParseConfigApps)

if(NOT TARGET log4cpp::log4cpp)
  EnsureVarOrEnvSet(LOG4CPP_ENV_INC LOG4CPP_INC)
  if("${LOG4CPP_ENV_INC}" STREQUAL "LOG4CPP_ENV_INC-NOTFOUND")
    find_program(LOG4CPPCONFIG NAMES log4cpp-config)
    if("${LOG4CPPCONFIG}" STREQUAL "LOG4CPPCONFIG-NOTFOUND")
      cmessage(WARNING "Could not find log4cpp-config, but LOG4CPP_INC is not set in the environment")
      SET(log4cpp_FOUND FALSE)
      return()
    endif()

    execute_process (COMMAND log4cpp-config --prefix 
                      OUTPUT_VARIABLE LOG4CPP_PREFIX 
                      OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(LOG4CPP_ENV_INC ${LOG4CPP_PREFIX}/include)
    cmessage(STATUS "Used log4cpp-config to resolve LOG4CPP_INC=${LOG4CPP_ENV_INC}")
  endif()

  find_path(LOG4CPP_INC
    NAMES log4cpp/config.h
    PATHS ${LOG4CPP_ENV_INC})

  if("${LOG4CPP_INC}" STREQUAL "LOG4CPP_INC-NOTFOUND")
    cmessage(WARNING "When configuring GENIE with LOG4CPP_INC=\"${LOG4CPP_ENV_INC}\", failed find required file \"log4cpp/config.h\".")
    SET(log4cpp_FOUND FALSE)
    return()
  endif()

  EnsureVarOrEnvSet(LOG4CPP_ENV_LIB LOG4CPP_LIB)
  if("${LOG4CPP_ENV_LIB}" STREQUAL "LOG4CPP_ENV_LIB-NOTFOUND")
    find_program(LOG4CPPCONFIG NAMES log4cpp-config)
    if("${LOG4CPPCONFIG}" STREQUAL "LOG4CPPCONFIG-NOTFOUND")
      cmessage(WARNING "Could not find log4cpp-config, but LOG4CPP_LIB is not set in the environment")
      SET(log4cpp_FOUND FALSE)
      return()
    endif()

    GetLibDir(CONFIG_APP log4cpp-config ARGS --libs OUTPUT_VARIABLE LOG4CPP_ENV_LIB)
    cmessage(STATUS "Used log4cpp-config to resolve LOG4CPP_LIB=${LOG4CPP_ENV_LIB}")
  endif()

  find_path(LOG4CPP_LIB
    NAMES liblog4cpp.so
    PATHS ${LOG4CPP_ENV_LIB})

  if("${LOG4CPP_LIB}" STREQUAL "LOG4CPP_LIB-NOTFOUND")
    cmessage(WARNING "When configuring GENIE with LOG4CPP_LIB=\"${LOG4CPP_ENV_LIB}\", failed find required file \"liblog4cpp.so\".")
    SET(log4cpp_FOUND FALSE)
    return()
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(log4cpp
      REQUIRED_VARS 
        LOG4CPP_INC
        LOG4CPP_LIB
  )

  if(NOT log4cpp_FOUND)
    return()
  endif()

  cmessage(STATUS "Found log4cpp:")
  cmessage(STATUS "     LOG4CPP_INC: ${LOG4CPP_INC}")
  cmessage(STATUS "     LOG4CPP_LIB: ${LOG4CPP_LIB}")

  add_library(log4cpp::log4cpp INTERFACE IMPORTED)
  set_target_properties(log4cpp::log4cpp PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${LOG4CPP_INC}
      INTERFACE_LINK_DIRECTORIES ${LOG4CPP_LIB}
      INTERFACE_LINK_LIBRARIES log4cpp
    )

endif()