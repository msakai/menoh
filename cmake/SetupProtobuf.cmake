set(PROTOBUF_VERSION "2.6.1")

if(UNIX AND LINK_STATIC_LIBPROTOBUF)
    set(PROTOBUF_DIR ${CMAKE_CURRENT_BINARY_DIR}/protobuf-${PROTOBUF_VERSION})
    set(PROTOBUF_URL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-${PROTOBUF_VERSION}.tar.gz")
    set(PROTOBUF_HASH MD5=f3916ce13b7fcb3072a1fa8cf02b2423)

    # Requires `-fPIC` for linking with a shared library
    set(PROTOBUF_CFLAGS -fPIC)
    set(PROTOBUF_CXXFLAGS -fPIC)
    if(USE_OLD_GLIBCXX_ABI)
        set(PROTOBUF_CXXFLAGS "${PROTOBUF_CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0")
    endif()

    ExternalProject_Add(Protobuf
        PREFIX ${PROTOBUF_DIR}
        URL ${PROTOBUF_URL}
        URL_HASH ${PROTOBUF_HASH}
        DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./configure --prefix=${PROTOBUF_DIR} CFLAGS=${PROTOBUF_CFLAGS} CXXFLAGS=${PROTOBUF_CXXFLAGS}
        BUILD_COMMAND make
        INSTALL_COMMAND make install
    )

    set(Protobuf_LIBRARY_STATIC ${PROTOBUF_DIR}/lib/libprotobuf.a)
    set(Protobuf_LIBRARY_SHARED ${PROTOBUF_DIR}/lib/libprotobuf.so)

    add_library(protobuf::libprotobuf.a STATIC IMPORTED)
    # Note: INTERFACE_INCLUDE_DIRECTORIES can't set in this place because include/ is
    # not installed during executing `cmake`
    set_target_properties(protobuf::libprotobuf.a PROPERTIES
        IMPORTED_LOCATION "${Protobuf_LIBRARY_STATIC}")

    # mimic the behavior of FindProtobuf module
    set(Protobuf_INCLUDE_DIR ${PROTOBUF_DIR}/include)
    set(Protobuf_LIBRARY protobuf::libprotobuf.a) # use the static library
    set(Protobuf_LIBRARIES ${Protobuf_LIBRARY})
    set(Protobuf_PROTOC_EXECUTABLE ${PROTOBUF_DIR}/bin/protoc)
    set(Protobuf_FOUND TRUE)
else()
    include(FindProtobuf)
    find_package(Protobuf ${PROTOBUF_VERSION} REQUIRED)
endif()

include_directories(${Protobuf_INCLUDE_DIR})