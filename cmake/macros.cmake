# Easy grouping of source and header files

	# HeaderGroup (TargetName must be the name of the directory the target's CMakeLists.txt is in)
	function(HeaderGroup p_target_name p_group_name p_install_directory)
		set(Files "")
		
		foreach(arg IN LISTS ARGN)
			list(APPEND Files ${arg})
		endforeach()
		
		set("${p_group_name}_header_files"
			"${Files}"
		)
		
		source_group("Header Files\\${p_group_name}" FILES ${${p_group_name}_header_files})
		
		get_target_property(target_type ${p_target_name} TYPE)
		
		if(${target_type} STREQUAL "INTERFACE_LIBRARY")
			
			if(TARGET ${p_target_name}_ide)
			
				set_property(TARGET ${p_target_name}_ide APPEND PROPERTY SOURCES ${${p_group_name}_header_files})
				#target_sources(${p_target_name}_ide PRIVATE ${${p_group_name}_header_files})
		
			endif()
		
		else()
		
			target_sources(${p_target_name} PRIVATE ${${p_group_name}_header_files})
		
		endif()
		
		if("${${p_target_name}_CC_SCOPE}" STREQUAL "PUBLIC")
			
			install(
				FILES
					${Files}
				DESTINATION
					"include/${p_install_directory}"
			)
			
		endif()
		
	endfunction()

	# PrivateHeaderGroup
	function(PrivateHeaderGroup p_target_name p_group_name)
		set(Files "")
		
		foreach(arg IN LISTS ARGN)
			list(APPEND Files ${arg})
		endforeach()
		
		set("${p_group_name}_header_files"
			"${Files}"
		)
		
		source_group("Header Files\\${p_group_name}" FILES ${${p_group_name}_header_files})
		
		get_target_property(target_type ${p_target_name} TYPE)
		
		if("${target_type}" STREQUAL "INTERFACE_LIBRARY")
			
			if(TARGET "${p_target_name}_ide")
			
				set_property(TARGET ${p_target_name}_ide APPEND PROPERTY SOURCES ${${p_group_name}_header_files})
				#target_sources(${p_target_name}_ide PRIVATE ${${p_group_name}_header_files})
		
			endif()
		
		else()
		
			target_sources(${p_target_name} PRIVATE ${${p_group_name}_header_files})
		
		endif()
		
	endfunction()

	# SourceGroup
	function(SourceGroup p_target_name p_group_name)
		set(Files "")

		foreach(arg IN LISTS ARGN)
			list(APPEND Files ${arg})
		endforeach()
		
		set("${p_group_name}_source_files"
			"${Files}"
		)
		
		source_group("Source Files\\${p_group_name}" FILES ${${p_group_name}_source_files})
		
		get_target_property(target_type ${p_target_name} TYPE)
		
		if(${target_type} STREQUAL "INTERFACE_LIBRARY")
			
			if(TARGET ${p_target_name}_ide)
			
				set_property(TARGET ${p_target_name}_ide APPEND PROPERTY SOURCES ${${p_group_name}_source_files})
				#target_sources(${p_target_name}_ide PRIVATE ${${p_group_name}_source_files})
		
			endif()
		
		else()
		
			target_sources(${p_target_name} PRIVATE ${${p_group_name}_source_files})
		
		endif()
		
	endfunction()

	# FileGroup
	function(FileGroup p_target_name p_group_name)
		set(Files "")

		foreach(arg IN LISTS ARGN)
			list(APPEND Files ${arg})
		endforeach()
		
		set("${p_group_name}_noncode_files"
			"${Files}"
		)
		
		source_group("${p_group_name}" FILES ${${p_group_name}_noncode_files})
		
		get_target_property(target_type ${p_target_name} TYPE)
		
		if(${target_type} STREQUAL "INTERFACE_LIBRARY")
			
			if(TARGET ${p_target_name}_ide)
			
				target_sources(${p_target_name}_ide PRIVATE ${${p_group_name}_noncode_files})
				
			endif()
		
		else()
		
			target_sources(${p_target_name} PRIVATE ${${p_group_name}_noncode_files})
		
		endif()
		
	endfunction()

# Easy grouping of targets (Consider TargetGroup rename)
function(TargetGroup p_target_name p_group_name)
	
	get_target_property(target_type ${p_target_name} TYPE)
	
	if(${target_type} STREQUAL "INTERFACE_LIBRARY")
			
		set_target_properties(${p_target_name}_ide PROPERTIES FOLDER ${p_group_name})
	
	else()
	
		set_target_properties(${p_target_name} PROPERTIES FOLDER ${p_group_name})
	
	endif()
		
endfunction()

function(PrintTargetType p_target_name)
	get_target_property(target_type ${p_target_name} TYPE)
	message(STATUS "Target ${p_target_name} is of type ${target_type} and of scope ${${p_target_name}_CC_SCOPE}.")
endfunction()

# Export Target Group
macro(ExportTargetGroup TargetGroup Namespace Version ConfigFile)

	install(EXPORT "${TargetGroup}Targets"
		FILE "${TargetGroup}Targets.cmake"
		NAMESPACE ${Namespace}::
		DESTINATION lib/cmake/${TargetGroup}
	)

	include(CMakePackageConfigHelpers)
	
	write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${TargetGroup}ConfigVersion.cmake"
		VERSION ${Version}
		COMPATIBILITY SameMajorVersion
	)
	
	configure_file(${ConfigFile} "${CMAKE_CURRENT_BINARY_DIR}/${TargetGroup}Config.cmake" COPYONLY)
	
	install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${TargetGroup}Config.cmake" "${CMAKE_CURRENT_BINARY_DIR}/${TargetGroup}ConfigVersion.cmake"
		DESTINATION lib/cmake/${TargetGroup}
	)
	
endmacro()

function(LibraryIncludeDirectory p_library_name p_directory p_install_directory)

	get_target_property(target_type ${p_library_name} TYPE)

	if(${${p_library_name}_CC_SCOPE} STREQUAL "PRIVATE")
	
		if(${target_type} STREQUAL "INTERFACE_LIBRARY")
	
			target_include_directories(${p_library_name} INTERFACE $<BUILD_INTERFACE:${p_directory}>)
			#target_include_directories(${p_library_name}_ide PUBLIC $<BUILD_INTERFACE:${p_directory}>)
			
		elseif(${target_type} STREQUAL "STATIC_LIBRARY" OR ${target_type} STREQUAL "SHARED_LIBRARY")
		
			target_include_directories(${p_library_name} PUBLIC $<BUILD_INTERFACE:${p_directory}>)
		
		else()
		
			message(FATAL_ERROR "Invalid target type: ${target_type}")
		
		endif()
	
	elseif(${${p_library_name}_CC_SCOPE} STREQUAL "PUBLIC")
	
		if(${target_type} STREQUAL "INTERFACE_LIBRARY")
	
			target_include_directories(${p_library_name} INTERFACE $<BUILD_INTERFACE:${p_directory}>)
			#target_include_directories(${p_library_name}_ide PUBLIC $<BUILD_INTERFACE:${p_directory}>)
			target_include_directories(${p_library_name} INTERFACE $<INSTALL_INTERFACE:include/${p_install_directory}>)
			
		elseif(${target_type} STREQUAL "STATIC_LIBRARY" OR ${target_type} STREQUAL "SHARED_LIBRARY")
		
			target_include_directories(${p_library_name} PUBLIC $<BUILD_INTERFACE:${p_directory}>)
			target_include_directories(${p_library_name} PUBLIC $<INSTALL_INTERFACE:include/${p_install_directory}>)
		
		else()
		
			message(FATAL_ERROR "Invalid target type: ${target_type}")
		
		endif()
	
	else()
	
		message(FATAL_ERROR "Invalid ${p_library_name}_CC_SCOPE = ${${p_library_name}_CC_SCOPE}.")
	
	endif()
	
endfunction()

function(LibraryPrivateIncludeDirectory p_library_name p_directory)

	get_target_property(target_type ${p_library_name} TYPE)

	if(${target_type} STREQUAL "INTERFACE_LIBRARY")

		#target_include_directories(${p_library_name}_ide PRIVATE $<BUILD_INTERFACE:${p_directory}>)
		target_include_directories(${p_library_name} PRIVATE $<BUILD_INTERFACE:${p_directory}>)
		
	elseif(${target_type} STREQUAL "STATIC_LIBRARY" OR ${target_type} STREQUAL "SHARED_LIBRARY")
	
		target_include_directories(${p_library_name} PRIVATE $<BUILD_INTERFACE:${p_directory}>)
	
	else()
	
		message(FATAL_ERROR "Invalid target type: ${target_type}")
	
	endif()
	
endfunction()

# Add Basic Library (Note: Can't EXPORT HEADERONLY libraries, for now)
macro(AddLibrary p_library_name p_scope p_type p_target_group p_namespace) # TYPE: STATIC, SHARED, HEADERONLY, SCOPE: PUBLIC, PRIVATE
	if(${p_type} STREQUAL "STATIC")
		add_library(${p_library_name} STATIC "")
	elseif(${p_type} STREQUAL "SHARED")
		add_library(${p_library_name} SHARED "")
	elseif(${p_type} STREQUAL "HEADERONLY")
		add_library(${p_library_name} INTERFACE)
		add_custom_target(${p_library_name}_ide)
	else()
		message(FATAL_ERROR "Invalid Library Type (Must be STATIC, SHARED or HEADERONLY)")
	endif()
	
	set(${p_library_name}_CC_SCOPE ${p_scope})
	
	if(${p_scope} STREQUAL "PUBLIC")
		add_library(${Namespace}::${p_library_name} ALIAS ${p_library_name})
		#target_include_directories(${p_library_name} PUBLIC $<INSTALL_INTERFACE:include>) ###???
		
		if(NOT ${p_type} STREQUAL "HEADERONLY")
		
			install(TARGETS ${p_library_name} EXPORT "${p_target_group}Targets"
				LIBRARY DESTINATION lib
				ARCHIVE DESTINATION lib
				RUNTIME DESTINATION bin
				INCLUDES DESTINATION include
			)
		endif()
	elseif(${p_scope} STREQUAL "PRIVATE")
		
	else()
		message(FATAL_ERROR "Invalid Library Scope (Must be PUBLIC or PRIVATE)")
	endif()
	
	PrintTargetType(${p_library_name})
	
endmacro()

# Add Basic Private Library (Not Exported and not in any exported target interfaces)
macro(AddPrivateLibrary p_library_name p_type)
	
	AddLibrary(${p_library_name} PRIVATE ${p_type} ${p_library_name} ${p_library_name})
	
endmacro()

# Add Path to Module Path
macro(AddCMakeModulePath Path)
	set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${Path})
endmacro()

macro(SetProjectVersion ProjectName Version)

	# setup global version variables
	set(${ProjectName}_VERSION ${Version})

	# Major, minor and patch version strings
	string(REPLACE "." ";" VERSION_LIST ${${ProjectName}_VERSION})
	list(GET VERSION_LIST 0 ${ProjectName}_VERSION_MAJOR)
	list(GET VERSION_LIST 1 ${ProjectName}_VERSION_MINOR)
	list(GET VERSION_LIST 2 ${ProjectName}_VERSION_PATCH)

	# full version string (This is to confirm correct formatting)
	set(${ProjectName}_VERSION ${${ProjectName}_VERSION_MAJOR}.${${ProjectName}_VERSION_MINOR}.${${ProjectName}_VERSION_PATCH})
	message("${ProjectName} Project version: ${${ProjectName}_VERSION}")
	
endmacro()

# Add Project Version
macro(AddProjectVersion ProjectName VersionFile)

	# setup global version variables
	file(READ ${VersionFile} ${ProjectName}_VERSION)

	SetProjectVersion(${ProjectName} ${${ProjectName}_VERSION})

endmacro()

macro(SetProjectVersionFromFile ProjectName VersionFile)
	
	AddProjectVersion(${ProjectName} ${VersionFile})
	
endmacro()

macro(SetDefaultInstallPrefix)

	if(NOT CMAKE_INSTALL_PREFIX_CC_DEFAULT)
	
		set (CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/bin" CACHE PATH "Install Path" FORCE)	
		set (CMAKE_INSTALL_PREFIX_CC_DEFAULT "TRUE" CACHE PATH "" FORCE)
		mark_as_advanced(CMAKE_INSTALL_PREFIX_CC_DEFAULT)

	endif()
	
endmacro()