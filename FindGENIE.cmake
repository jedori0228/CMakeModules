if(NOT TARGET GENIE::All)
  
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

if(NOT DEFINED GENIE2_FOUND)
  set(GENIE2_FOUND FALSE)
elseif(GENIE2_FOUND) #We might have already found the version-specifc one
  add_library(GENIE::All INTERFACE IMPORTED)
  set_target_properties(GENIE::All PROPERTIES
      INTERFACE_LINK_LIBRARIES GENIE2::All
  )
  SET(GENIE_FOUND TRUE)
endif()

if(NOT DEFINED GENIE3_FOUND)
  set(GENIE3_FOUND FALSE)
elseif(GENIE3_FOUND) #We might have already found the version-specifc one
  add_library(GENIE::All INTERFACE IMPORTED)
  set_target_properties(GENIE::All PROPERTIES
      INTERFACE_LINK_LIBRARIES GENIE3::All
  )
  SET(GENIE_FOUND TRUE)
endif()

if(NOT GENIE_FOUND)
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
endif()

endif()