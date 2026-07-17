cmake_minimum_required(VERSION 3.16)

project(MobileCameraClient VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 COMPONENTS Quick REQUIRED)

# qt_policy(SET QTP0001 NEW)

qt_add_executable(appMobileCameraClient
    main.cpp
)

qt_add_qml_module(appMobileCameraClient
    URI MobileCameraClient
    VERSION 1.0
    QML_FILES
        main.qml
        CameraStream.qml
    RESOURCES
        icons/up.svg
        icons/down.svg
        icons/left.svg
        icons/right.svg
        icons/zoom_in.svg
        icons/zoom_out.svg
        icons/back.svg
        icons/menu.svg
    SOURCES
        ptzcontroller.h
        ptzcontroller.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMobileCameraClient PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMobileCameraClient
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMobileCameraClient
    PRIVATE Qt6::Quick)

include(GNUInstallDirs)
install(TARGETS appMobileCameraClient
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
