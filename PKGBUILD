# Maintainer: Masahiro Sakai <masahiro.sakai@gmail.com>

_realname=menoh
_onnxversion=1.2.1
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=1.0.3
pkgrel=1
pkgdesc="Menoh - DNN inference library (mingw-w64)"
arch=('x86_64')
url='https://github.com/pfnet-research/menoh'
license=('MIT License')
depends=("${MINGW_PACKAGE_PREFIX}-mkl-dnn"
          "${MINGW_PACKAGE_PREFIX}-opencv"
          "${MINGW_PACKAGE_PREFIX}-protobuf")
makedepends=("${MINGW_PACKAGE_PREFIX}-gcc"
             "${MINGW_PACKAGE_PREFIX}-cmake"
             "${MINGW_PACKAGE_PREFIX}-mkl-dnn"
             "${MINGW_PACKAGE_PREFIX}-opencv"
             "${MINGW_PACKAGE_PREFIX}-protobuf")
options=('staticlibs' 'strip')
source=("git+https://github.com/pfnet-research/menoh.git#commit=fa85238191d3cc205cc0daebd536f1d731cbb776"
        onnx-${_onnxversion}.tar.gz::https://github.com/onnx/onnx/archive/v${_onnxversion}.tar.gz)
sha256sums=('SKIP' 'SKIP')

prepare() {
  cd "${srcdir}/${_realname}"
  rm -rf external/onnx
  cp -R ${srcdir}/onnx-${_onnxversion} external/onnx
}

build() {
  [[ -d "${srcdir}/build-${MINGW_CHOST}" ]] && rm -rf "${srcdir}/build-${MINGW_CHOST}"
  mkdir "${srcdir}/build-${MINGW_CHOST}"
  cd "${srcdir}/build-${MINGW_CHOST}"
  MSYS2_ARG_CONV_EXCL="-DCMAKE_INSTALL_PREFIX=;-DMKLDNN_LIBRARY=;-DPROTOBUF_LIBRARY=" \
  ${MINGW_PREFIX}/bin/cmake.exe \
    -G "MSYS Makefiles" \
    -DCMAKE_INSTALL_PREFIX=${MINGW_PREFIX} \
    -DMKLDNN_LIBRARY=${MINGW_PREFIX}/lib/libmkldnn.dll.a \
    -DPROTOBUF_LIBRARY=${MINGW_PREFIX}/lib/libprotobuf.dll.a \
    "${srcdir}/${_realname}"
  make -j1
}

package() {
  cd "${srcdir}/build-${MINGW_CHOST}"
  make DESTDIR="${pkgdir}" install
  install -Dm644 -t "${pkgdir}${MINGW_PREFIX}/libexec/${_realname}" example/*.exe benchmark/*.exe

  cd "${srcdir}/${_realname}"
  install -Dm755 -t "${pkgdir}${MINGW_PREFIX}/share/doc/${_realname}" LICENSE README.md docs/*
}
