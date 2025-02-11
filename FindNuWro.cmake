if(NOT TARGET NuWro::All)

  include(CMessage)
  include(NuHepMCUtils)
  EnsureVarOrEnvSet(NUWRO NUWRO)

  if("${NUWRO}" STREQUAL "NUWRO-NOTFOUND")
    cmessage(STATUS "NUWRO environment variable is not defined, assuming no NuWro build")
    SET(NuWro_FOUND FALSE)
    return()
  endif()

  include(FindPackageHandleStandardArgs)

  find_path(NuWro_INC_DIR
    NAMES dis/dis_cc.h
    PATHS ${NUWRO}/include)

  find_path(NuWro_LIB_DIR
    NAMES event1.so
    PATHS ${NUWRO}/lib)

  find_package_handle_standard_args(NuWro
    REQUIRED_VARS 
      NUWRO 
      NuWro_INC_DIR 
      NuWro_LIB_DIR
  )

  if(NuWro_FOUND)

    cmessage(STATUS "NuWro found: ${NUWRO}")
    cmessage(STATUS "       NuWro_INC_DIR: ${NuWro_INC_DIR}")
    cmessage(STATUS "       NuWro_LIB_DIR: ${NuWro_LIB_DIR}")

    if(NOT TARGET NuWro::event1)
      add_library(NuWro::event1 UNKNOWN IMPORTED)
      set_target_properties(NuWro::event1 PROPERTIES
        IMPORTED_NO_SONAME ON
        IMPORTED_LOCATION ${NUWRO}/bin/event1.so
        )
    endif()

    if(NOT TARGET NuWro::All)
      add_library(NuWro::All INTERFACE IMPORTED)
      set_target_properties(NuWro::All PROPERTIES
          INTERFACE_INCLUDE_DIRECTORIES "${NuWro_INC_DIR}"
          INTERFACE_COMPILE_OPTIONS "-DNuWro_ENABLED"
          INTERFACE_LINK_LIBRARIES NuWro::event1
      )
    endif()

  endif()

endif()
