include(CMessage)
include(NuHepMCUtils)

if(NOT DEFINED GENIEVersion_FOUND OR NOT GENIEVersion_FOUND)

  SET(GENIEVersion_FOUND TRUE)

  find_program(GENIECONFIG NAMES genie-config)
  if("${GENIECONFIG}" STREQUAL "GENIECONFIG-NOTFOUND")
    cmessage(STATUS "Could not find genie-config, assuming no GENIE build")
    SET(GENIEVersion_FOUND FALSE)
    return()
  endif()

  EnsureVarOrEnvSet(GENIE GENIE)

  if("${GENIE}" STREQUAL "GENIE-NOTFOUND")
    cmessage(STATUS "GENIE environment variable is not defined, assuming no GENIE build")
    SET(GENIEVersion_FOUND FALSE)
    return()
  endif()

  execute_process (COMMAND cat ${GENIE}/VERSION OUTPUT_VARIABLE GENIE_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(NOT EXISTS ${GENIE}/VERSION)
    cmessage(STATUS "When configuring GENIE, we failed to find \${GENIE}/VERSION, which is required.")
    SET(GENIEVersion_FOUND FALSE)
    return()
  endif()

endif()