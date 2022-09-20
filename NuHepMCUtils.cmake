include(CMessage)

if(NOT COMMAND EnsureVarOrEnvSet)

# If ${OUT_VARNAME} is defined and not empty, this is a no-op
# If ${OUT_VARNAME} is undefiend or empty then first $ENV{${VARNAME}} 
# and then ${${VARNAME}} are checked, if either are defined and non-empty, 
# ${OUT_VARNAME} is set equal to them in the parent scope.
function(EnsureVarOrEnvSet OUT_VARNAME VARNAME)
  set(options UNSET_IS_FATAL)
  cmake_parse_arguments(OPTS 
                      "${options}" 
                      "${oneValueArgs}"
                      "${multiValueArgs}" ${ARGN})

  if(NOT DEFINED ${OUT_VARNAME} OR "${${OUT_VARNAME}}x" STREQUAL "x")
    if(DEFINED ENV{${VARNAME}} AND NOT "$ENV{${VARNAME}}x" STREQUAL "x")
      set(${OUT_VARNAME} $ENV{${VARNAME}} PARENT_SCOPE)
      cmessage(DEBUG "[EnsureVarOrEnvSet] Variable \"${OUT_VARNAME}\" set to the value of environment variable \"${VARNAME}\"=\"$ENV{${VARNAME}}\"")
      return()
    endif()
    if(DEFINED ${VARNAME} AND NOT "${${VARNAME}}x" STREQUAL "x")
      set(${OUT_VARNAME} ${${VARNAME}} PARENT_SCOPE)
      cmessage(DEBUG "[EnsureVarOrEnvSet] Variable \"${OUT_VARNAME}\" set to the value of CMake variable \"${VARNAME}\"=\"${${VARNAME}}\"")
      return()
    endif()
  else()
    cmessage(DEBUG "[EnsureVarOrEnvSet] Variable \"${OUT_VARNAME}\" already set to \"${${OUT_VARNAME}}\"")
    return()
  endif()

  if(OPTS_UNSET_IS_FATAL)
    cmessage(FATAL_ERROR "${OUT_VARNAME} undefined, either configure with -D${VARNAME}=<value> or set ${VARNAME} into the environment")
  else()
    cmessage(DEBUG "[EnsureVarOrEnvSet] Variable \"${OUT_VARNAME}\" is not set as \"${VARNAME}\" is not set in CMake or in the environment.")
    set(${OUT_VARNAME} ${OUT_VARNAME}-NOTFOUND PARENT_SCOPE)
  endif()

endfunction()
endif()

if(NOT COMMAND EnsureVarSet)

# If ${OUT_VARNAME} is defined and not empty, this is a no-op
# If ${OUT_VARNAME} is undefiend or empty then set to DEFVAL
function(EnsureVarSet OUT_VARNAME DEFVAL)

  if(NOT DEFINED ${OUT_VARNAME} OR "${${OUT_VARNAME}}x" STREQUAL "x")
    set(${OUT_VARNAME} ${DEFVAL} PARENT_SCOPE)
    cmessage(DEBUG "[EnsureVarSet] Set variable \"${OUT_VARNAME}\" to default value: \"${DEFVAL}\"")
  endif()
  cmessage(DEBUG "[EnsureVarSet] Variable \"${OUT_VARNAME}\" already set to \"${${OUT_VARNAME}}\"")

endfunction()
endif()

if(NOT COMMAND dump_cmake_variables)
function(dump_cmake_variables)
    set(DEBUG_BUILDSYSTEMGENERATOR TRUE)
    
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        if (ARGV0)
            unset(MATCHED)
            string(REGEX MATCH ${ARGV0} MATCHED ${_variableName})
            if (NOT MATCHED)
                continue()
            endif()
        endif()
        cmessage(DEBUG "${_variableName}=${${_variableName}}")
    endforeach()
endfunction()
endif()

if(NOT COMMAND has_parent_scope)
  function(has_parent_scope RETURN_VAR)
    get_directory_property(hasParent PARENT_DIRECTORY)
    if(hasParent)
      set(${RETURN_VAR} TRUE PARENT_SCOPE)
    else()
      set(${RETURN_VAR} FALSE PARENT_SCOPE)
    endif()
  endfunction()
endif()