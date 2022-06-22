if(NOT TARGET GENIE3::All)

  find_package(GENIEVersion)
  if(NOT GENIEVersion_FOUND)
    SET(GENIE3_FOUND FALSE)
    return()
  endif()

  include(NuHepMCUtils)
  EnsureVarOrEnvSet(GENIE_REWEIGHT GENIE_REWEIGHT)

  set(GENIE_REWEIGHT_FOUND FALSE)
  if("${GENIE_REWEIGHT}" STREQUAL "GENIE_REWEIGHT-NOTFOUND")
    cmessage(STATUS "GENIE_REWEIGHT environment variable is not defined, assuming no GENIE_REWEIGHT build")
  endif()

  find_path(GENIE_INC_DIR
    NAMES Framework/GHEP/GHepRecord.h
    PATHS ${GENIE}/include/GENIE)

  find_path(GENIE_LIB_DIR
    NAMES libGFwGHEP.so
    PATHS ${GENIE}/lib)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(GENIE3
    REQUIRED_VARS 
      GENIE 
      GENIE_INC_DIR 
      GENIE_LIB_DIR
    VERSION_VAR GENIE_VERSION
  )

  if(GENIE3_FOUND)

    find_package(GENIEDependencies)
    if(NOT GENIEDependencies_FOUND)
      SET(GENIE3_FOUND FALSE)
      return()
    endif()

    include(ParseConfigApps)

    GetLibs(CONFIG_APP genie-config ARGS --libs OUTPUT_VARIABLE GENIE_LIBS)

    string(REGEX REPLACE "\([0-9]\)\.\([0-9]*\).*" "\\1\\2" GENIE_SINGLE_VERSION ${GENIE_VERSION})
    string(LENGTH "${GENIE_SINGLE_VERSION}" GENIE_SINGLE_VERSION_STRLEN)
    if(GENIE_SINGLE_VERSION_STRLEN LESS 3)
      string(APPEND GENIE_SINGLE_VERSION "0")
    endif()
      
    LIST(APPEND GENIE_DEFINES -DGENIE_ENABLED -DGENIE3_API_ENABLED -DGENIE_VERSION=${GENIE_SINGLE_VERSION})

    set(GENIEReWeight_ENABLED TRUE)
    foreach(RWLIBNAME GRwClc GRwFwk GRwIO)
      LIST(REMOVE_ITEM GENIE_LIBS ${RWLIBNAME})
      if(EXISTS ${GENIE_LIB_DIR}/lib${RWLIBNAME}.so)
        LIST(APPEND GENIE_LIBS ${RWLIBNAME})
      else()
        cmessage(WARNING "Failed to find expected reweight library: ${GENIE_LIB_DIR}/lib${RWLIBNAME}.so disabling GENIE3 reweight.")
        set(GENIEReWeight_ENABLED FALSE)
      endif()
    endforeach()

    if(EXISTS ${GENIE_INC_DIR}/RwCalculators/GReWeightXSecMEC.h)
      SET(GENIE3_XSECMEC_ENABLED TRUE)
    endif()


    #duplicate because CMake gets its grubby mitts on repeated -Wl,--start-group options
    SET(GENIE_LIBS "-Wl,--no-as-needed;${GENIE_LIBS};${GENIE_LIBS};-Wl,--as-needed")
    SET(GENIE_DEP_LIBS EGPythia6 Pythia6::Pythia6 LHAPDF::LHAPDF log4cpp::log4cpp LibXml2::LibXml2 GSL::gsl)

    cmessage(STATUS "GENIE 3 (Version: ${GENIE_VERSION})")
    cmessage(STATUS "                GENIE: ${GENIE}")
    cmessage(STATUS "       GENIE_REWEIGHT: ${GENIE_REWEIGHT}")
    cmessage(STATUS "              OPTIONS: GENIEReWeight: ${GENIEReWeight_ENABLED}, XSecMECReWeight: ${GENIE3_XSECMEC_ENABLED}")
    cmessage(STATUS " GENIE_SINGLE_VERSION: ${GENIE_SINGLE_VERSION}")
    cmessage(STATUS "        GENIE DEFINES: ${GENIE_DEFINES}")
    cmessage(STATUS "       GENIE INC_DIRS: ${GENIE_INC_DIR}")
    cmessage(STATUS "       GENIE LIB_DIRS: ${GENIE_LIB_DIR}")
    cmessage(STATUS "           GENIE LIBS: ${GENIE_LIBS}")
    cmessage(STATUS "            DEPS LIBS: ${GENIE_DEP_LIBS}")

    add_library(GENIE3::All INTERFACE IMPORTED)
    set_target_properties(GENIE3::All PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${GENIE_INC_DIR}"
        INTERFACE_COMPILE_OPTIONS "${GENIE_DEFINES}"
        INTERFACE_LINK_DIRECTORIES "${GENIE_LIB_DIR}"
        INTERFACE_LINK_LIBRARIES "${GENIE_LIBS};${GENIE_DEP_LIBS}"
    )

    set(GENIE3_API_ENABLED TRUE)
  endif()

endif()
