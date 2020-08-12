# check if variables are set
test -n "${PROTOBUF_VERSION}" || { echo "PROTOBUF_VERSION can't be empty" 1>&2; exit 1; }
test -n "${MKLDNN_VERSION}" || { echo "MKLDNN_VERSION can't be empty" 1>&2; exit 1; }
test -n "${MAKE_JOBS}" || { echo "MAKE_JOBS can't be empty" 1>&2; exit 1; }

test -n "${LINK_STATIC}" || LINK_STATIC=false
test -n "${BUILD_STATIC_LIBS}" || BUILD_STATIC_LIBS=false

# TODO: make them configurable for outside Travis
export WORK_DIR=${HOME}
export PROJ_DIR=${TRAVIS_BUILD_DIR} # = ${HOME}/build/${TRAVIS_REPO_SLUG}

export PROTOBUF_INSTALL_DIR=/usr/local
export MKLDNN_INSTALL_DIR=/usr/local

# Run a docker container and map Travis's $HOME to the container's $HOME
# $HOME:$HOME = /home/travis                     : /home/travis
#               /home/travis/build               : /home/travis/build
#               /home/travis/build/<user>/<repo> : /home/travis/build/<user>/<repo> (= ${TRAVIS_BUILD_DIR})
SOURCE_DIR=$(cd "$(dirname "${BASH_SOURCE:-$0}/..")"; pwd)
source ${SOURCE_DIR}/scripts/run-container.sh --image ${BUILDENV_IMAGE} --work-dir ${WORK_DIR}
test -n "${BUILDENV_CONTAINER_ID}" || { echo "BUILDENV_CONTAINER_ID can't be empty" 1>&2; exit 1; }

## define shared functions for Linux-based platforms

# Run the specified string as command in the container
function docker_exec() {
    docker exec -it ${BUILDENV_CONTAINER_ID} /bin/bash -xec "$1"
    return $?
}

# Run the specified shell script in the container
function docker_exec_script() {
    docker exec -it ${BUILDENV_CONTAINER_ID} /bin/bash -xe $@
    return $?
}

function build_protobuf() {
    docker_exec_script \
        "${PROJ_DIR}/scripts/build-protobuf.sh" \
            --version ${PROTOBUF_VERSION} \
            --download-dir "${WORK_DIR}/downloads" \
            --extract-dir "${WORK_DIR}/build" \
            --install-dir "${PROTOBUF_INSTALL_DIR}" \
            --parallel ${MAKE_JOBS}
}

function install_protobuf() {
    docker_exec_script \
        "${PROJ_DIR}/scripts/install-protobuf.sh" \
            --build-dir "${WORK_DIR}/build/protobuf-${PROTOBUF_VERSION}"
}

function build_mkldnn() {
    docker_exec_script \
        "${PROJ_DIR}/scripts/build-mkldnn.sh" \
            --version ${MKLDNN_VERSION} \
            --download-dir "${WORK_DIR}/downloads" \
            --extract-dir "${WORK_DIR}/build" \
            --install-dir "${MKLDNN_INSTALL_DIR}" \
            --parallel ${MAKE_JOBS}
}

function install_mkldnn() {
    docker_exec_script \
        "${PROJ_DIR}/scripts/install-mkldnn.sh" \
            --build-dir "${WORK_DIR}/build/oneDNN-${MKLDNN_VERSION}/build"
}

function prepare_menoh_data() {
    docker_exec_script \
        "${PROJ_DIR}/scripts/prepare-menoh-data.sh" \
            --source-dir "${PROJ_DIR}" \
            --python-executable python3
}

function build_menoh() {
    if [ "${BUILD_STATIC_LIBS}" = "true" ]; then
        docker_exec_script \
            "${PROJ_DIR}/scripts/build-menoh.sh" \
                --build-type Release \
                --source-dir "${PROJ_DIR}" \
                --python-executable python3 \
                --build-shared-libs OFF
    elif [ "${LINK_STATIC}" != "true" ]; then
        docker_exec_script \
            "${PROJ_DIR}/scripts/build-menoh.sh" \
                --build-type Release \
                --source-dir "${PROJ_DIR}" \
                --python-executable python3
    else
        docker_exec_script \
            "${PROJ_DIR}/scripts/build-menoh.sh" \
                --build-type Release \
                --source-dir "${PROJ_DIR}" \
                --python-executable python3 \
                --link-static-libgcc ON \
                --link-static-libstdcxx ON \
                --link-static-libprotobuf ON
    fi
}

function test_menoh() {
    docker_exec "cd \"${PROJ_DIR}/build\" && ./test/menoh_test"
}

function check_menoh_artifact() {
    if [ "${BUILD_STATIC_LIBS}" != "true" ]; then
        docker_exec "ldd \"${PROJ_DIR}/build/menoh/libmenoh.so\""
    fi
}
