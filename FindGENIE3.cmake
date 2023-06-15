if(NOT TARGET GENIE3::All)

  include(NuHepMCUtils)

  SET(GENIE3_FOUND FALSE)

  EnsureVarSet(GENIE3_XSECMEC_ENABLED FALSE)
  EnsureVarSet(GENIEReWeight_ENABLED FALSE)

  find_package(GENIEVersion)
  if(NOT GENIEVersion_FOUND)
    return()
  endif()

  find_package(ROOT 6 REQUIRED COMPONENTS EGPythia6)

  EnsureVarOrEnvSet(GENIE_REWEIGHT GENIE_REWEIGHT)
  # Needed for FNAL gpvms
  EnsureVarOrEnvSet(GENIE_LIB GENIE_LIB)

  find_path(GENIE_INC_DIR
    NAMES Framework/GHEP/GHepRecord.h
    PATHS ${GENIE}/include/GENIE ${GENIE}/src)

  find_path(GENIE_LIB_DIR
    NAMES libGFwGHEP.so
    PATHS ${GENIE}/lib ${GENIE_LIB})

  find_path(GENIE_RW_LIB_DIR
    NAMES libGRwIO.so
    PATHS ${GENIE}/lib ${GENIE_LIB} ${GENIE_REWEIGHT}/lib)

  find_path(GENIE_RW_INC_DIR
    NAMES RwFramework/GReWeight.h
    PATHS ${GENIE_REWEIGHT}/src)

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

    GetLibs(CONFIG_APP genie-config ARGS --libs 
      OUTPUT_VARIABLE GENIE_LIBS
      RESULT_VARIABLE GENIECONFIG_RETVAL)

    #We can't use genie-config, try and build the list manually
    if(NOT GENIECONFIG_RETVAL EQUAL 0)
      file(GLOB GENIELIBLIST ${GENIE}/lib/lib*.so)
      foreach(lib ${GENIELIBLIST})
        get_filename_component(libname ${lib} NAME_WLE)
        if (libname MATCHES "lib.*-[0-9]+\\.[0-9]+\\.[0-9]+")
          continue()
        endif()
        string(REGEX REPLACE "lib(.*)" "\\1" name ${libname})
        LIST(APPEND GENIE_LIBS ${name})
      endforeach()
    endif()

    string(REGEX REPLACE "([0-9]*)\\.([0-9]*).*" "\\1\\2" GENIE_SINGLE_VERSION ${GENIE_VERSION})
    string(LENGTH "${GENIE_SINGLE_VERSION}" GENIE_SINGLE_VERSION_STRLEN)
    if(GENIE_SINGLE_VERSION_STRLEN LESS 3)
      string(APPEND GENIE_SINGLE_VERSION "0")
    endif()

    LIST(APPEND GENIE_DEFINES -DGENIE_ENABLED -DGENIE_VERSION=${GENIE_SINGLE_VERSION})

    set(GENIEReWeight_ENABLED TRUE)
    # Remove the libraries from GENIE libs, if we think we can find them, 
    #   we will append them again in a moment
    foreach(RWLIBNAME GRwClc GRwFwk GRwIO)
      LIST(REMOVE_ITEM GENIE_LIBS ${RWLIBNAME})
    endforeach()

    if( (GENIE_RW_INC_DIR  STREQUAL "GENIE_RW_INC_DIR-NOTFOUND") 
        OR (GENIE_RW_LIB_DIR  STREQUAL "GENIE_RW_LIB_DIR-NOTFOUND") )
      set(GENIEReWeight_ENABLED FALSE)
    else()
      foreach(RWLIBNAME GRwClc GRwFwk GRwIO)
        if(EXISTS ${GENIE_RW_LIB_DIR}/lib${RWLIBNAME}.so)
          LIST(APPEND GENIE_LIBS ${RWLIBNAME})
        else()
          cmessage(WARNING "Failed to find expected reweight library: ${GENIE_RW_LIB_DIR}/lib${RWLIBNAME}.so disabling GENIE3 reweight.")
          set(GENIEReWeight_ENABLED FALSE)
        endif()
      endforeach()

      if(EXISTS ${GENIE_RW_INC_DIR}/RwCalculators/GReWeightXSecMEC.h)
        SET(GENIE3_XSECMEC_ENABLED TRUE)
      endif()
    endif()

    #duplicate because CMake gets its grubby mitts on repeated -Wl,--start-group options
    SET(GENIE_LIBS "-Wl,--no-as-needed;${GENIE_LIBS};${GENIE_LIBS};-Wl,--as-needed")
    SET(GENIE_DEP_LIBS ROOT::EGPythia6 ROOT::RIO ROOT::Core Pythia6::Pythia6 LHAPDF::LHAPDF log4cpp::log4cpp LibXml2::LibXml2 GSL::gsl)

    LIST(APPEND GENIE_ALL_INC_DIRS ${GENIE_INC_DIR})
    LIST(APPEND GENIE_ALL_LIB_DIRS ${GENIE_LIB_DIR})
    if(GENIEReWeight_ENABLED)
      LIST(APPEND GENIE_ALL_LIB_DIRS ${GENIE_RW_LIB_DIR})
      LIST(APPEND GENIE_ALL_INC_DIRS ${GENIE_RW_INC_DIR})
    endif()

    cmessage(STATUS "GENIE 3 (Version: ${GENIE_VERSION})")
    cmessage(STATUS "                GENIE: ${GENIE}")
    cmessage(STATUS "       GENIE_REWEIGHT: ${GENIE_REWEIGHT}")
    cmessage(STATUS "              OPTIONS: GENIEReWeight: ${GENIEReWeight_ENABLED}, XSecMECReWeight: ${GENIE3_XSECMEC_ENABLED}")
    cmessage(STATUS " GENIE_SINGLE_VERSION: ${GENIE_SINGLE_VERSION}")
    cmessage(STATUS "        GENIE DEFINES: ${GENIE_DEFINES}")
    cmessage(STATUS "       GENIE INC_DIRS: ${GENIE_ALL_INC_DIRS}")
    cmessage(STATUS "       GENIE LIB_DIRS: ${GENIE_ALL_LIB_DIRS}")
    cmessage(STATUS "           GENIE LIBS: ${GENIE_LIBS}")
    cmessage(STATUS "            DEPS LIBS: ${GENIE_DEP_LIBS}")


    add_library(GENIE3::All INTERFACE IMPORTED)
    set_target_properties(GENIE3::All PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${GENIE_ALL_INC_DIRS}"
      INTERFACE_COMPILE_OPTIONS "${GENIE_DEFINES}"
      INTERFACE_LINK_DIRECTORIES "${GENIE_ALL_LIB_DIRS}"
      INTERFACE_LINK_LIBRARIES "${GENIE_LIBS};${GENIE_DEP_LIBS}"
      )

  endif()

endif()
