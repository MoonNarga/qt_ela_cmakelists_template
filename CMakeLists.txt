cmake_minimum_required(VERSION 3.29)
project(NewLaser VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)
message(STATUS "QT_DIR: ${QT_DIR}")

list(APPEND src_files "main.cpp")
set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
file(GLOB_RECURSE CPP_FILES "${SRC_DIR}/*.cpp" "${SRC_DIR}/*.h")
foreach (filepath ${CPP_FILES})
    string(REPLACE "${SRC_DIR}/" "src/" filename ${filepath})
    list(APPEND src_files ${filename})
endforeach ()

set(PROJECT_SOURCES
        ${src_files}
)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/config.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/config.cmake)
endif ()

if (${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(NewLaser
            MANUAL_FINALIZATION
            ${PROJECT_SOURCES}
    )

    #遍历所有资源文件
    file(GLOB_RECURSE RES_PATHS *.png *.jpg *.svg *.ico *.ttf *.webp *.js)
    foreach (filepath ${RES_PATHS})
        string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
        list(APPEND resource_files ${filename})
    endforeach (filepath)

    qt_add_resources(${PROJECT_NAME} "NewLaser"
            RESOURCES PREFIX "/"
            FILES
            ${resource_files}
    )
    # Define target properties for Android with Qt 6 as:
    #    set_property(TARGET NewLaser APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
    #                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
    # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else ()
    if (ANDROID)
        add_library(NewLaser SHARED
                ${PROJECT_SOURCES}
        )
        # Define properties for Android with Qt 5 after find_package() calls as:
        #    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else ()
        qt5_add_big_resources(PROJECT_SOURCES
                ${QRC}
        )
        add_executable(NewLaser
                ${PROJECT_SOURCES}
        )
    endif ()
endif ()

include_directories(
        src
        src/ModelView
)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})

target_link_libraries(NewLaser PRIVATE
        Qt${QT_VERSION_MAJOR}::Widgets
        $<$<CONFIG:Debug>:elawidgettoolsd>
        $<$<CONFIG:Release>:elawidgettools>
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
if (${QT_VERSION} VERSION_LESS 6.1.0)
    set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.NewLaser)
endif ()
set_target_properties(NewLaser PROPERTIES
        ${BUNDLE_ID_OPTION}
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
)

# copy 3rd party dlls
add_custom_command(TARGET NewLaser POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_RUNTIME_DLLS:NewLaser>
        $<TARGET_FILE_DIR:NewLaser>
        COMMENT "Target Runtime DLLs copied to $<TARGET_FILE_DIR:NewLaser>"
        COMMAND_EXPAND_LISTS
)

# deploy Qt runtime dependencies with windeployqt
if (WIN32)
    add_custom_command(TARGET NewLaser POST_BUILD
            COMMAND "${QT_DIR}/../../../bin/windeployqt.exe" $<$<CONFIG:Debug>:--debug> $<$<CONFIG:Release>:--release> "$<TARGET_FILE:NewLaser>"
            COMMENT "Deploying Qt runtime dependencies with windeployqt"
    )
endif ()

include(GNUInstallDirs)
install(TARGETS NewLaser
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if (QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(NewLaser)
endif ()
