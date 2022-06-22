cmake_minimum_required (VERSION 3.14 FATAL_ERROR)
# This will define the following variables
#
#    GENIE_FOUND
#    GENIEReWeight_ENABLED
#    GENIE2_FOUND
#    GENIE3_FOUND
#
#    GENIE2_XSECEMPMEC_ENABLED
#
#    GENIE3_API_ENABLED
#    GENIE3_XSECMEC_ENABLED
#
# This will declare the following imported targets on successful completion
#
#    GENIE::All
#


set(GENIEReWeight_ENABLED FALSE)

set(GENIE2_XSECEMPMEC_ENABLED FALSE)

set(GENIE3_API_ENABLED FALSE)
set(GENIE3_XSECMEC_ENABLED FALSE)

set(GENIE2_FOUND FALSE)
set(GENIE3_FOUND FALSE)

include(CMessage)
include(ParseConfigApps)

find_package(GENIEVersion)
if(NOT GENIEVersion_FOUND)
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