set(GENIEReWeight_ENABLED FALSE)

set(GENIE2_XSECEMPMEC_ENABLED FALSE)

set(GENIE3_API_ENABLED FALSE)
set(GENIE3_XSECMEC_ENABLED FALSE)

set(GENIE2_FOUND FALSE)
set(GENIE3_FOUND FALSE)

include(CMessage)
include(ParseConfigApps)

find_program(GENIECONFIG NAMES genie-config)
if("${GENIECONFIG}" STREQUAL "GENIECONFIG-NOTFOUND")
  cmessage(STATUS "Could not find genie-config, assuming no GENIE build")
  SET(GENIE_FOUND FALSE)
  return()
endif()

EnsureVarOrEnvSet(GENIE GENIE)

if("${GENIE}" STREQUAL "GENIE-NOTFOUND")
  cmessage(STATUS "GENIE environment variable is not defined, assuming no GENIE build")
  SET(GENIE_FOUND FALSE)
  return()
endif()

execute_process (COMMAND cat ${GENIE}/VERSION OUTPUT_VARIABLE GENIE_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE)

#Check and set up GENIE Dependencies
find_package(Pythia6)
if(NOT Pythia6_FOUND)
  SET(GENIE_FOUND FALSE)
  return()
endif()

find_package(LHAPDF)
if(NOT LHAPDF_FOUND)
  SET(GENIE_FOUND FALSE)
  return()
endif()

find_package(log4cpp)
if(NOT log4cpp_FOUND)
  SET(GENIE_FOUND FALSE)
  return()
endif()

###### LibXml2
find_package(LibXml2)
if(NOT TARGET LibXml2::LibXml2)
  SET(LibXml2_FOUND TRUE)

  cmessage(STATUS "Attempting to use environment to find libxml2")
  EnsureVarOrEnvSet(LIBXML2_INC LIBXML2_INC)
  EnsureVarOrEnvSet(LIBXML2_LIB LIBXML2_LIB)

  if("${LIBXML2_INC}" STREQUAL "LIBXML2_INC-NOTFOUND")
    cmessage(STATUS "Variable LIBXML2_INC is not defined. Please export environment variable LIBXML2_INC or configure with -DLIBXML2_INC=/path/to/libxml2/includes.")
    SET(LibXml2_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  if("${LIBXML2_LIB}" STREQUAL "LIBXML2_LIB-NOTFOUND")
    cmessage(STATUS "Variable LIBXML2_LIB is not defined. Please export environment variable LIBXML2_LIB or configure with -DLIBXML2_LIB=/path/to/libxml2/lib.")
    SET(LibXml2_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  find_path(LIBXML2_INC_DIR
    NAMES libxml/parser.h
    PATHS ${LIBXML2_INC})

  if("${LIBXML2_INC_DIR}" STREQUAL "LIBXML2_INC_DIR-NOTFOUND")
    cmessage(STATUS "When configuring GENIE with LIBXML2_INC=\"${LIBXML2_INC}\", failed find required file \"libxml/parser.h\".")
    SET(LibXml2_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  find_path(LIBXML2_LIB_DIR
    NAMES libxml2.so
    PATHS ${LIBXML2_LIB})

  if("${LIBXML2_LIB_DIR}" STREQUAL "LIBXML2_LIB_DIR-NOTFOUND")
    cmessage(STATUS "When configuring GENIE with LIBXML2_LIB=\"${LIBXML2_LIB}\", failed find required file \"libxml2.so\".")
    SET(LibXml2_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  cmessage(STATUS "Found LibXml2:")
  cmessage(STATUS "     LIBXML2_INC: ${LIBXML2_INC}")
  cmessage(STATUS "     LIBXML2_LIB: ${LIBXML2_LIB}")

  add_library(LibXml2::LibXml2 INTERFACE IMPORTED)
  set_target_properties(LibXml2::LibXml2 PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${LIBXML2_INC}
      INTERFACE_LINK_DIRECTORIES ${LIBXML2_LIB}
      INTERFACE_LINK_LIBRARIES xml2
    )
endif()

if(NOT LibXml2_FOUND)
  SET(GENIE_FOUND FALSE)
  return()
endif()

###### GSL
find_package(GSL)
if(NOT TARGET GSL::gsl)
  SET(GSL_FOUND TRUE)
  cmessage(STATUS "Attempting to use environment to find GSL")
  EnsureVarOrEnvSet(GSL_INC GSL_INC)
  EnsureVarOrEnvSet(GSL_LIB GSL_LIB)

  if("${GSL_INC}" STREQUAL "GSL_INC-NOTFOUND")
    cmessage(STATUS "Variable GSL_INC is not defined. Please export environment variable GSL_INC or configure with -DGSL_INC=/path/to/GSL/includes.")
    SET(GSL_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  if("${GSL_LIB}" STREQUAL "GSL_LIB-NOTFOUND")
    cmessage(STATUS "Variable GSL_LIB is not defined. Please export environment variable GSL_LIB or configure with -DGSL_LIB=/path/to/GSL/lib.")
    SET(GSL_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  find_path(GSL_INC_DIR
    NAMES gsl/gsl_version.h
    PATHS ${GSL_INC})

  if("${GSL_INC_DIR}" STREQUAL "GSL_INC_DIR-NOTFOUND")
    cmessage(STATUS "When configuring GENIE with GSL_INC=\"${GSL_INC}\", failed find required file \"libxml/parser.h\".")
    SET(GSL_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  find_path(GSL_LIB_DIR
    NAMES libgsl.so
    PATHS ${GSL_LIB})

  if("${GSL_LIB_DIR}" STREQUAL "GSL_LIB_DIR-NOTFOUND")
    cmessage(STATUS "When configuring GENIE with GSL_LIB=\"${GSL_LIB}\", failed find required file \"libgsl.so\".")
    SET(GSL_FOUND FALSE)
    SET(GENIE_FOUND FALSE)
    return()
  endif()

  cmessage(STATUS "Found gsl:")
  cmessage(STATUS "     GSL_INC: ${GSL_INC}")
  cmessage(STATUS "     GSL_LIB: ${GSL_LIB}")

  add_library(GSL::gslcblas INTERFACE IMPORTED)
  set_target_properties(GSL::gsl PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${GSL_INC}
      INTERFACE_LINK_DIRECTORIES ${GSL_LIB}
      INTERFACE_LINK_LIBRARIES "gslcblas;m"
    )

  add_library(GSL::gsl INTERFACE IMPORTED)
  set_target_properties(GSL::gsl PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${GSL_INC}
      INTERFACE_LINK_DIRECTORIES ${GSL_LIB}
      INTERFACE_LINK_LIBRARIES "gsl;GSL::gslcblas"
    )

endif()

if(NOT GSL_FOUND)
  SET(GENIE_FOUND FALSE)
  return()
endif()

if(NOT EXISTS ${GENIE}/VERSION)
  cmessage(STATUS "When configuring GENIE, we failed to find \${GENIE}/VERSION, which is required.")
  SET(GENIE_FOUND FALSE)
  return()
endif()

if(GENIE_VERSION VERSION_GREATER 2.99.99)
	find_package(GENIE3)
  if(NOT GENIE3_FOUND)
    SET(GENIE_FOUND FALSE)
    return()
  else()
    SET(GENIE_FOUND TRUE)
  endif()

  add_library(GENIE::All INTERFACE IMPORTED)
  set_target_properties(GENIE::All PROPERTIES
      INTERFACE_LINK_LIBRARIES GENIE3::All
  )
else()
	find_package(GENIE2)
  if(NOT GENIE2_FOUND)
    SET(GENIE_FOUND FALSE)
    return()
  else()
    SET(GENIE_FOUND TRUE)
  endif()

  add_library(GENIE::All INTERFACE IMPORTED)
  set_target_properties(GENIE::All PROPERTIES
      INTERFACE_LINK_LIBRARIES GENIE2::All
  )
endif()

if(GENIE_FOUND)
	target_link_libraries(GeneratorCompileDependencies INTERFACE GENIE::All)
endif()