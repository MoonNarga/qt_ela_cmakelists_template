set(INCLUDE_DIRS
        "C:/Users/MoonN/Workspace/Repos/ElaWidgetTools/src/include"
)

set(LIB_DIRS
        "C:/Users/MoonN/Workspace/Repos/ElaWidgetTools/build/Debug"
        "C:/Users/MoonN/Workspace/Repos/ElaWidgetTools/build/Release"
)

set(DLL_DIRS
        "C:/Users/MoonN/Workspace/Repos/ElaWidgetTools/build/Debug"
        "C:/Users/MoonN/Workspace/Repos/ElaWidgetTools/build/Release"
)

foreach (INCLUDE_DIR IN LISTS INCLUDE_DIRS)
    include_directories(${INCLUDE_DIR})
endforeach ()

# 初始化文件列表
set(ALL_LIB_FILES)

# 扫描 .lib 文件目录
foreach (LIB_DIR IN LISTS LIB_DIRS)
    file(GLOB LIB_FILES_IN_DIR "${LIB_DIR}/*.lib")
    list(APPEND ALL_LIB_FILES ${LIB_FILES_IN_DIR})
endforeach ()

# 扫描 .dll 文件目录并创建一个映射，方便根据库名查找对应的 DLL 文件
foreach (DLL_DIR IN LISTS DLL_DIRS)
    file(GLOB DLL_FILES_IN_DIR "${DLL_DIR}/*.dll")
    foreach (DLL_FILE IN LISTS DLL_FILES_IN_DIR)
        # 获取 DLL 文件的名称（不含路径和扩展名）
        get_filename_component(DLL_NAME "${DLL_FILE}" NAME_WE)
        # 将 DLL 名称和路径添加到映射中
        set(DLL_NAME_TO_PATH_MAP_${DLL_NAME} "${DLL_FILE}")
    endforeach ()
endforeach ()

foreach(LIB_FILE IN LISTS ALL_LIB_FILES)
    # 获取 LIB 文件的名称（不含路径和扩展名）
    get_filename_component(LIB_NAME "${LIB_FILE}" NAME_WE)

    # 检查是否存在同名的 DLL 文件
    set(DLL_FILE "")
    if(DEFINED DLL_NAME_TO_PATH_MAP_${LIB_NAME})
        set(DLL_FILE "${DLL_NAME_TO_PATH_MAP_${LIB_NAME}}")
    endif()

    # 创建 IMPORTED 目标
    if(EXISTS "${DLL_FILE}")
        # 创建 IMPORTED 共享库目标
        add_library(${LIB_NAME} SHARED IMPORTED)
        set_target_properties(${LIB_NAME} PROPERTIES
                IMPORTED_IMPLIB "${LIB_FILE}"
                IMPORTED_LOCATION "${DLL_FILE}"
        )
    else()
        # 没有对应的 DLL，创建 IMPORTED 静态库目标
        add_library(${LIB_NAME} STATIC IMPORTED)
        set_target_properties(${LIB_NAME} PROPERTIES
                IMPORTED_LOCATION "${LIB_FILE}"
        )
    endif()

endforeach()

# for qt5_add_big_resources
set(QRC "C:/Users/MoonN/Workspace/Repos/ElaWidgetTools/src/include/ElaWidgetTools.qrc")
