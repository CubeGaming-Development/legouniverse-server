cmake_minimum_required(VERSION 3.18)
project(Darkflame)
include(CTest)

set (CMAKE_CXX_STANDARD 17)

# Read variables from file
FILE(READ "${CMAKE_SOURCE_DIR}/CMakeVariables.txt" variables)

string(REPLACE "\\\n" "" variables ${variables})
string(REPLACE "\n" ";" variables ${variables})

# Set the cmake variables, formatted as "VARIABLE #" in variables
foreach(variable ${variables})
	# If the string contains a #, skip it
	if(NOT "${variable}" MATCHES "#")

		# Split the variable into name and value
		string(REPLACE "=" ";" variable ${variable})

		# Check that the length of the variable is 2 (name and value)
		list(LENGTH variable length)
		if(${length} EQUAL 2)

			list(GET variable 0 variable_name)
			list(GET variable 1 variable_value)

			# Set the variable
			set(${variable_name} ${variable_value})

			# Add compiler definition
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D${variable_name}=${variable_value}")

			message(STATUS "Variable: ${variable_name} = ${variable_value}")
		endif()
	endif()
endforeach()

# Set the version
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")

# Echo the version
message(STATUS "Version: ${PROJECT_VERSION}")

# Disable demo, tests and examples for recastNavigation.  Turn these to ON if you want to use them
# This has to be done here to prevent a rare build error due to missing dependencies on the initial generations.
set(RECASTNAVIGATION_DEMO OFF CACHE BOOL "" FORCE)
set(RECASTNAVIGATION_TESTS OFF CACHE BOOL "" FORCE)
set(RECASTNAVIGATION_EXAMPLES OFF CACHE BOOL "" FORCE)

# Compiler flags:
# Disabled deprecated warnings as the MySQL includes have deprecated code in them.
# Disabled misleading indentation as DL_LinkedList from RakNet has a weird indent.
# Disabled no-register
# Disabled unknown pragmas because Linux doesn't understand Windows pragmas.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPROJECT_VERSION=${PROJECT_VERSION}")
if(UNIX)
	if(APPLE)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++17 -O2 -Wuninitialized -D_GLIBCXX_USE_CXX11_ABI=0 -D_GLIBCXX_USE_CXX17_ABI=0 -fPIC")
	else()
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++17 -O2 -Wuninitialized -D_GLIBCXX_USE_CXX11_ABI=0 -D_GLIBCXX_USE_CXX17_ABI=0 -static-libgcc -fPIC -lstdc++fs")
	endif()
	if (__dynamic AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -rdynamic")
	endif()
	if (__ggdb)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb")
	endif()
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -O2 -fPIC")
elseif(MSVC)
	# Skip warning for invalid conversion from size_t to uint32_t for all targets below for now
	add_compile_options("/wd4267" "/utf-8")
elseif(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

# Our output dir
set(CMAKE_BINARY_DIR ${PROJECT_BINARY_DIR})

# TODO make this not have to override the build type directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR})

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Create a /resServer directory
make_directory(${CMAKE_BINARY_DIR}/resServer)

# Create a /logs directory
make_directory(${CMAKE_BINARY_DIR}/logs)

# Copy resource files on first build
set(RESOURCE_FILES "sharedconfig.ini" "authconfig.ini" "chatconfig.ini" "worldconfig.ini" "masterconfig.ini" "blacklist.dcf")
foreach(resource_file ${RESOURCE_FILES})
	if (NOT EXISTS ${PROJECT_BINARY_DIR}/${resource_file})
		configure_file(
			${CMAKE_SOURCE_DIR}/resources/${resource_file} ${PROJECT_BINARY_DIR}/${resource_file}
			COPYONLY
		)
		message("Moved ${resource_file} to project binary directory")
	endif()
endforeach()

# Copy navmesh data on first build and extract it
if (NOT EXISTS ${PROJECT_BINARY_DIR}/navmeshes/)
	configure_file(
		${CMAKE_SOURCE_DIR}/resources/navmeshes.zip ${PROJECT_BINARY_DIR}/navmeshes.zip
		COPYONLY
	)

	file(ARCHIVE_EXTRACT INPUT ${PROJECT_BINARY_DIR}/navmeshes.zip)
	file(REMOVE ${PROJECT_BINARY_DIR}/navmeshes.zip)
endif()

# Copy vanity files on first build
set(VANITY_FILES "CREDITS.md" "INFO.md" "TESTAMENT.md" "NPC.xml")
foreach(file ${VANITY_FILES})
	configure_file("${CMAKE_SOURCE_DIR}/vanity/${file}" "${CMAKE_BINARY_DIR}/vanity/${file}" COPYONLY)
endforeach()

# Move our migrations for MasterServer to run
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/migrations/dlu/)
file(GLOB SQL_FILES ${CMAKE_SOURCE_DIR}/migrations/dlu/*.sql)
foreach(file ${SQL_FILES})
	get_filename_component(file ${file} NAME)
	if (NOT EXISTS ${PROJECT_BINARY_DIR}/migrations/dlu/${file})
		configure_file(
			${CMAKE_SOURCE_DIR}/migrations/dlu/${file} ${PROJECT_BINARY_DIR}/migrations/dlu/${file}
			COPYONLY
		)
	endif()
endforeach()

file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/migrations/cdserver/)
file(GLOB SQL_FILES ${CMAKE_SOURCE_DIR}/migrations/cdserver/*.sql)
foreach(file ${SQL_FILES})
	get_filename_component(file ${file} NAME)
	if (NOT EXISTS ${PROJECT_BINARY_DIR}/migrations/cdserver/${file})
		configure_file(
			${CMAKE_SOURCE_DIR}/migrations/cdserver/${file} ${PROJECT_BINARY_DIR}/migrations/cdserver/${file}
			COPYONLY
		)
	endif()
endforeach()

# Create our list of include directories
set(INCLUDED_DIRECTORIES
	"dCommon"
	"dCommon/dClient"
	"dCommon/dEnums"
	"dChatFilter"
	"dGame"
	"dGame/dBehaviors"
	"dGame/dComponents"
	"dGame/dGameMessages"
	"dGame/dInventory"
	"dGame/dMission"
	"dGame/dEntity"
	"dGame/dPropertyBehaviors"
	"dGame/dPropertyBehaviors/ControlBehaviorMessages"
	"dGame/dUtilities"
	"dPhysics"
	"dNavigation"
	"dNavigation/dTerrain"
	"dZoneManager"
	"dDatabase"
	"dDatabase/Tables"
	"dNet"
	"dScripts"
	"dScripts/02_server"
	"dScripts/ai"
	"dScripts/client"
	"dScripts/EquipmentScripts"
	"dScripts/EquipmentTriggers"
	"dScripts/zone"
	"dScripts/02_server/DLU"
	"dScripts/02_server/Enemy"
	"dScripts/02_server/Equipment"
	"dScripts/02_server/Map"
	"dScripts/02_server/Minigame"
	"dScripts/02_server/Objects"
	"dScripts/02_server/Pets"
	"dScripts/02_server/Enemy/AG"
	"dScripts/02_server/Enemy/AM"
	"dScripts/02_server/Enemy/FV"
	"dScripts/02_server/Enemy/General"
	"dScripts/02_server/Enemy/Survival"
	"dScripts/02_server/Enemy/VE"
	"dScripts/02_server/Enemy/Waves"
	"dScripts/02_server/Map/AG"
	"dScripts/02_server/Map/AG_Spider_Queen"
	"dScripts/02_server/Map/AM"
	"dScripts/02_server/Map/FV"
	"dScripts/02_server/Map/General"
	"dScripts/02_server/Map/GF"
	"dScripts/02_server/Map/njhub"
	"dScripts/02_server/Map/NS"
	"dScripts/02_server/Map/NT"
	"dScripts/02_server/Map/PR"
	"dScripts/02_server/Map/Property"
	"dScripts/02_server/Map/SS"
	"dScripts/02_server/Map/VE"
	"dScripts/02_server/Map/FV/Racing"
	"dScripts/02_server/Map/General/Ninjago"
	"dScripts/02_server/Map/njhub/boss_instance"
	"dScripts/02_server/Map/NS/Waves"
	"dScripts/02_server/Map/Property/AG_Med"
	"dScripts/02_server/Map/Property/AG_Small"
	"dScripts/02_server/Map/Property/NS_Med"
	"dScripts/02_server/Minigame/General"
	"dScripts/ai/ACT"
	"dScripts/ai/AG"
	"dScripts/ai/FV"
	"dScripts/ai/GENERAL"
	"dScripts/ai/GF"
	"dScripts/ai/MINIGAME"
	"dScripts/ai/NP"
	"dScripts/ai/NS"
	"dScripts/ai/PETS"
	"dScripts/ai/PROPERTY"
	"dScripts/ai/RACING"
	"dScripts/ai/SPEC"
	"dScripts/ai/WILD"
	"dScripts/ai/ACT/FootRace"
	"dScripts/ai/MINIGAME/SG_GF"
	"dScripts/ai/MINIGAME/SG_GF/SERVER"
	"dScripts/ai/NS/NS_PP_01"
	"dScripts/ai/NS/WH"
	"dScripts/ai/PROPERTY/AG"
	"dScripts/ai/RACING/OBJECTS"
	"dScripts/client/ai"
	"dScripts/client/ai/PR"
	"dScripts/zone/AG"
	"dScripts/zone/LUPs"
	"dScripts/zone/PROPERTY"
	"dScripts/zone/PROPERTY/FV"
	"dScripts/zone/PROPERTY/GF"
	"dScripts/zone/PROPERTY/NS"

	"thirdparty/raknet/Source"
	"thirdparty/tinyxml2"
	"thirdparty/recastnavigation"
	"thirdparty/SQLite"
	"thirdparty/cpplinq"

	"tests"
	"tests/dCommonTests"
	"tests/dGameTests"
	"tests/dGameTests/dComponentsTests"
	)

# Add system specfic includes for Apple, Windows and Other Unix OS' (including Linux)
if (APPLE)
	include_directories("/usr/local/include/")
endif()

if (WIN32)
	set(INCLUDED_DIRECTORIES ${INCLUDED_DIRECTORIES} "thirdparty/libbcrypt/include")
elseif (UNIX)
	set(INCLUDED_DIRECTORIES ${INCLUDED_DIRECTORIES} "thirdparty/libbcrypt")
	set(INCLUDED_DIRECTORIES ${INCLUDED_DIRECTORIES} "thirdparty/libbcrypt/include/bcrypt")
endif()

# Add binary directory as an include directory
include_directories(${PROJECT_BINARY_DIR})

# Actually include the directories from our list
foreach (dir ${INCLUDED_DIRECTORIES})
	include_directories(${PROJECT_SOURCE_DIR}/${dir})
endforeach()

# Add linking directories:
link_directories(${PROJECT_BINARY_DIR})

# Load all of our third party directories
add_subdirectory(thirdparty)

# Glob together all headers that need to be precompiled
file(
	GLOB HEADERS_DDATABASE
	LIST_DIRECTORIES false
	${PROJECT_SOURCE_DIR}/dDatabase/*.h
	${PROJECT_SOURCE_DIR}/dDatabase/Tables/*.h
	${PROJECT_SOURCE_DIR}/thirdparty/SQLite/*.h
)

file(
	GLOB HEADERS_DZONEMANAGER
	LIST_DIRECTORIES false
	${PROJECT_SOURCE_DIR}/dZoneManager/*.h
)

file(
	GLOB HEADERS_DCOMMON
	LIST_DIRECTORIES false
	${PROJECT_SOURCE_DIR}/dCommon/*.h
)

file(
	GLOB HEADERS_DGAME
	LIST_DIRECTORIES false
	${PROJECT_SOURCE_DIR}/dGame/Entity.h
	${PROJECT_SOURCE_DIR}/dGame/dGameMessages/GameMessages.h
	${PROJECT_SOURCE_DIR}/dGame/EntityManager.h
	${PROJECT_SOURCE_DIR}/dScripts/CppScripts.h
)

# Add our library subdirectories for creation of the library object
add_subdirectory(dCommon)
add_subdirectory(dDatabase)
add_subdirectory(dChatFilter)
add_subdirectory(dNet)
add_subdirectory(dScripts) # Add for dGame to use
add_subdirectory(dGame)
add_subdirectory(dZoneManager)
add_subdirectory(dNavigation)
add_subdirectory(dPhysics)

# Create a list of common libraries shared between all binaries
set(COMMON_LIBRARIES "dCommon" "dDatabase" "dNet" "raknet" "mariadbConnCpp")

# Add platform specific common libraries
if (UNIX)
	set(COMMON_LIBRARIES ${COMMON_LIBRARIES} "dl" "pthread")

	if (NOT APPLE AND __include_backtrace__)
		set(COMMON_LIBRARIES ${COMMON_LIBRARIES} "backtrace")
	endif()
endif()

# Include all of our binary directories
add_subdirectory(dWorldServer)
add_subdirectory(dAuthServer)
add_subdirectory(dChatServer)
add_subdirectory(dMasterServer) # Add MasterServer last so it can rely on the other binaries

# Add our precompiled headers
target_precompile_headers(
	dGame PRIVATE
	${HEADERS_DGAME}
)

target_precompile_headers(
	dZoneManager PRIVATE
	${HEADERS_DZONEMANAGER}
)

# Need to specify to use the CXX compiler language here or else we get errors including <string>.
target_precompile_headers(
	dDatabase PRIVATE
	"$<$<COMPILE_LANGUAGE:CXX>:${HEADERS_DDATABASE}>"
)

target_precompile_headers(
	dCommon PRIVATE
	${HEADERS_DCOMMON}
)

target_precompile_headers(
	tinyxml2 PRIVATE
	"$<$<COMPILE_LANGUAGE:CXX>:${PROJECT_SOURCE_DIR}/thirdparty/tinyxml2/tinyxml2.h>"
)

if (${__enable_testing__} MATCHES "1")
	add_subdirectory(tests)
endif()
