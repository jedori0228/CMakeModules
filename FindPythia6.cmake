include(CMessage)

if(NOT TARGET Pythia6::Pythia6)

  EnsureVarOrEnvSet(PYTHIA6 PYTHIA6)
  EnsureVarOrEnvSet(PYTHIA6_ENV_LIB_DIR PYTHIA6_LIB_DIR)
  EnsureVarOrEnvSet(PYTHIA6_LIBRARY PYTHIA6_LIBRARY)

  find_path(PYTHIA6_LIB_DIR
  NAMES libPythia6.so
  PATHS ${PYTHIA6} ${PYTHIA6_ENV_LIB_DIR} ${PYTHIA6_LIBRARY})

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Pythia6
      REQUIRED_VARS 
        PYTHIA6_LIB_DIR
  )

  if(NOT Pythia6_FOUND)
    return()
  endif()

  cmessage(STATUS "Found Pythia6:")
  cmessage(STATUS "     PYTHIA6_LIB_DIR: ${PYTHIA6_LIB_DIR}")

  add_library(Pythia6::Pythia6 INTERFACE IMPORTED)
  set_target_properties(Pythia6::Pythia6 PROPERTIES
      INTERFACE_LINK_DIRECTORIES ${PYTHIA6_LIB_DIR}
      INTERFACE_LINK_LIBRARIES Pythia6
    )
endif()
