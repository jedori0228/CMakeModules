include(CMessage)
include(NuHepMCUtils)

EnsureVarOrEnvSet(GENIE GENIE)
if("${GENIE}" STREQUAL "GENIE-NOTFOUND")
  cmessage(FindGENIEVersion.cmake "GENIE environment variable is not defined, assuming no GENIE build")
  return()
endif()

if(NOT DEFINED GENIEVersion_FOUND OR NOT GENIEVersion_FOUND)

  SET(GENIEVersion_FOUND FALSE)

  EnsureVarOrEnvSet(GENIE_VERSION GENIE_VERSION)

  if(DEFINED GENIE_VERSION AND GENIE_VERSION MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")
    cmessage(DEBUG "[FindGENIEVersion.cmake]: GENIE_VERSION is set to \"${GENIE_VERSION}\"")
    SET(GENIEVersion_FOUND TRUE)
    return()
  endif()

  find_program(GENIECONFIG NAMES genie-config)
  if(NOT "${GENIECONFIG}" STREQUAL "GENIECONFIG-NOTFOUND")
    execute_process (COMMAND genie-config --version 
      OUTPUT_VARIABLE GENIE_VERSION
      ERROR_VARIABLE GENIECONFIG_ERROR
      RESULT_VARIABLE GENIECONFIG_RETVAL
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_STRIP_TRAILING_WHITESPACE)

    if(GENIECONFIG_RETVAL EQUAL 0 AND GENIE_VERSION MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")
      SET(GENIEVersion_FOUND TRUE)
      cmessage(DEBUG "[FindGENIEVersion.cmake] Determined GENIE_VERSION=\"${GENIE_VERSION}\" from genie-config --version")
      return()
    else()
      cmessage(DEBUG "[FindGENIEVersion.cmake]: genie-config --version returned: \"${GENIE_VERSION}\"")
      cmessage(DEBUG "[FindGENIEVersion.cmake]: error code: ${GENIECONFIG_RETVAL}")
      cmessage(DEBUG "[FindGENIEVersion.cmake]: error message: ${GENIECONFIG_ERROR}")
      cmessage(DEBUG "[FindGENIEVersion.cmake]: Attempting to determine GENIE_VERSION in another way")
    endif()
  endif()

  EnsureVarOrEnvSet(GENIE GENIE)

  if("${GENIE}" STREQUAL "GENIE-NOTFOUND")
    cmessage(FindGENIEVersion.cmake "GENIE environment variable is not defined, assuming no GENIE build")
    return()
  endif()

  if(EXISTS ${GENIE}/VERSION)
    execute_process (COMMAND cat ${GENIE}/VERSION OUTPUT_VARIABLE GENIE_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    cmessage(DEBUG "[FindGENIEVersion.cmake] Determined GENIE_VERSION=\"${GENIE_VERSION}\" from ${GENIE}/VERSION")
    SET(GENIEVersion_FOUND TRUE)
    return()
  else()
    cmessage(DEBUG "[FindGENIEVersion.cmake] When configuring GENIE, we failed to find \${GENIE}/VERSION")
  endif()

  file(GLOB GENIELIBLIST ${GENIE}/lib/lib*.so)
  foreach(lib ${GENIELIBLIST})
    get_filename_component(libname ${lib} NAME_WLE)
    if(libname MATCHES "lib.*-[0-9]+\\.[0-9]+\\.[0-9]+")
      STRING(REGEX REPLACE "lib.*-([0-9]+\\.[0-9]+\\.[0-9]+)" "\\1" GENIE_VERSION ${libname})
      cmessage(DEBUG "[FindGENIEVersion.cmake] Extracted GENIE_VERSION=\"${GENIE_VERSION}\" from ${lib}")
      SET(GENIEVersion_FOUND TRUE)
      return()
    endif()
  endforeach()

  cmessage(FindGENIEVersion.cmake "Failed to determine GENIE version, configure with -DDEBUG_BUILDSYSTEMGENERATOR=ON to see more details")

endif()