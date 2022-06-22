if(NOT DEFINED NuHepMCCMakeModules_FOUND OR NOT NuHepMCCMakeModules_FOUND)

  SET(NuHepMCCMakeModules_FOUND TRUE)
  get_filename_component(NuHepMCCMakeModules_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
  LIST(APPEND CMAKE_MODULE_PATH ${NuHepMCCMakeModules_DIR})

  include(CMessage)

  cmessage(STATUS "[INFO]: Included NuHepMC CMakeModules from ${NuHepMCCMakeModules_DIR}")

endif()