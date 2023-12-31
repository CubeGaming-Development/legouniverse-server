SET(CPACK_PACKAGE_NAME "${LIBRARY_NAME}")
SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
SET(CPACK_SOURCE_PACKAGE_FILE_NAME "mariadb-connector-cpp-${CPACK_PACKAGE_VERSION}${QUALITY_SUFFIX}-src")
IF(NOT CPACK_PACKAGE_RELEASE)
  SET(CPACK_PACKAGE_RELEASE 1)
ENDIF()
SET(CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE 1)
SET(CPACK_PACKAGE_VENDOR "MariaDB Corporation Ab")
SET(CPACK_PACKAGE_CONTACT "info@mariadb.com")
SET(CPACK_PACKAGE_DESCRIPTION "MariaDB Connector/C++. C++ driver library for connecting to MariaDB and MySQL servers")
SET(CPACK_PACKAGE_LICENSE "LGPLv2.1")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
SET(CPACK_PACKAGE_API_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/")

IF(INSTALL_LAYOUT STREQUAL "DEFAULT")
  SET(CPACK_COMPONENTS_ALL ClientPlugins  CppLibs ConCLib Documentation PublicAPI)
ELSE()
  SET(CPACK_COMPONENTS_ALL CppLibs Documentation PublicAPI)
ENDIF()

IF(NOT SYSTEM_NAME)
  STRING(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME)
ENDIF()

SET(QUALITY_SUFFIX "")
IF (MACPP_VERSION_QUALITY AND NOT "${MACPP_VERSION_QUALITY}" STREQUAL "ga" AND NOT "${MACPP_VERSION_QUALITY}" STREQUAL "GA")
  SET(QUALITY_SUFFIX "-${MACPP_VERSION_QUALITY}")
ENDIF()

IF(PACKAGE_PLATFORM_SUFFIX)
  SET(CPACK_PACKAGE_FILE_NAME "mariadb-connector-cpp-${CPACK_PACKAGE_VERSION}${QUALITY_SUFFIX}-${PACKAGE_PLATFORM_SUFFIX}")
ELSE()
  SET(CPACK_PACKAGE_FILE_NAME "mariadb-connector-cpp-${CPACK_PACKAGE_VERSION}${QUALITY_SUFFIX}-${SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
ENDIF()

SET(CPACK_SOURCE_IGNORE_FILES
/test/
/.git/
.gitignore
.gitmodules
.gitattributes
CMakeCache.txt
cmake_dist.cmake
CPackSourceConfig.cmake
CPackConfig.cmake
/.build/
cmake_install.cmake
CTestTestfile.cmake
/CMakeFiles/
/version_resources/
.*vcxproj
.*gz$
.*zip$
.*so$
.*so.2
.*so.3
.*dll$
.*a$
.*pdb$
.*sln$
.*sdf$
install_manifest_*txt
Makefile$
tests_config.h
/autom4te.cache/
/.travis/
.travis.yml
/libmariadb/
/_CPack_Packages/
)

# Build source packages
IF(GIT_BUILD_SRCPKG OR CONNCPP_GIT_BUILD_SRCPKG)
  IF(WIN32)
    EXECUTE_PROCESS(COMMAND git archive --format=zip --prefix=${CPACK_SOURCE_PACKAGE_FILE_NAME}/ --output=${CPACK_SOURCE_PACKAGE_FILE_NAME}.zip --worktree-attributes -v HEAD)
  ELSE()
    EXECUTE_PROCESS(COMMAND git archive ${GIT_BRANCH} --format=zip --prefix=${CPACK_SOURCE_PACKAGE_FILE_NAME}/ --output=${CPACK_SOURCE_PACKAGE_FILE_NAME}.zip -v HEAD)
    EXECUTE_PROCESS(COMMAND git archive ${GIT_BRANCH} --format=tar --prefix=${CPACK_SOURCE_PACKAGE_FILE_NAME}/ --output=${CPACK_SOURCE_PACKAGE_FILE_NAME}.tar -v HEAD)
    EXECUTE_PROCESS(COMMAND gzip -9 -f ${CPACK_SOURCE_PACKAGE_FILE_NAME}.tar)
  ENDIF()
ENDIF()
IF(WIN32)
  SET(DEFAULT_GENERATOR "ZIP")
ELSE()
  SET(DEFAULT_GENERATOR "TGZ")
ENDIF()
IF(NOT CPACK_GENERATOR)
  SET(CPACK_GENERATOR "${DEFAULT_GENERATOR}")
ENDIF()
IF(NOT CPACK_SOURCE_GENERATOR)
  SET(CPACK_SOURCE_GENERATOR "${DEFAULT_GENERATOR}")
ENDIF()

#########################
# DEB and RPM packaging #
#########################
IF(DEB)
  SET(CPACK_GENERATOR "DEB")
  SET(CPACK_DEBIAN_PACKAGE_SECTION "devel")
  SET(CPACK_DEBIAN_PACKAGE_NAME ${CPACK_PACKAGE_NAME})
  SET(CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
  SET(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
  SET(CPACK_DEBIAN_PACKAGE_DEBUG ON)
  SET(CPACK_DEBIAN_DEBUGINFO_PACKAGE ON)
  SET(CPACK_DEB_COMPONENT_INSTALL    ON)
  SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
  SET(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION ON)
  EXECUTE_PROCESS(COMMAND lsb_release -sc OUTPUT_VARIABLE DIST OUTPUT_STRIP_TRAILING_WHITESPACE)
  IF(NOT DIST)
    SET(DIST ${DEB})
  ENDIF()
  SET(CPACK_DEBIAN_PACKAGE_RELEASE "${CPACK_PACKAGE_RELEASE}+maria~${DIST}")
ENDIF()
#
#
IF(RPM)
  SET(CPACK_GENERATOR "RPM")
  SET(CPACK_RPM_PACKAGE_DEBUG ON)
  SET(CPACK_RPM_PACKAGE_GROUP "Development/Libraries") # deprecated
  SET(CPACK_RPM_COMPONENT_INSTALL ON)
  IF(CMAKE_VERSION VERSION_LESS "3.6.0")
    SET(CPACK_RPM_PACKAGE_NAME ${CPACK_PACKAGE_NAME})
    EXECUTE_PROCESS(COMMAND rpm --eval %dist
                    OUTPUT_VARIABLE DIST OUTPUT_STRIP_TRAILING_WHITESPACE)
    SET(CPACK_RPM_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION})
    SET(CPACK_PACKAGE_FILE_NAME "${CPACK_RPM_PACKAGE_NAME}-${CPACK_RPM_PACKAGE_VERSION}-${CPACK_RPM_PACKAGE_RELEASE}${DIST}-${CMAKE_SYSTEM_PROCESSOR}")
  ELSE()
    SET(CPACK_RPM_FILE_NAME "RPM-DEFAULT")
    SET(CPACK_RPM_PACKAGE_RELEASE_DIST ON)
    OPTION(CPACK_RPM_DEBUGINFO_PACKAGE "" ON)
    SET(CPACK_RPM_BUILD_SOURCE_DIRS_PREFIX "/usr/src/debug/${CPACK_RPM_PACKAGE_NAME}-${CPACK_RPM_PACKAGE_VERSION}")
  ENDIF()
ENDIF()
#
INCLUDE(CPack)
