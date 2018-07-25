# Maintainer: Masahiro Sakai <masahiro.sakai@gmail.com>

_realname=menoh
_onnxversion=1.2.1
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=1.0.2
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
source=(${_realname}-${pkgver}.tar.gz::https://github.com/pfnet-research/menoh/archive/v${pkgver}.tar.gz
        onnx-${_onnxversion}.tar.gz::https://github.com/onnx/onnx/archive/v${_onnxversion}.tar.gz)
sha256sums=('e27ca3b594f26e4373d89dfbb28d1ead5ba9f30179d6321f115bc96e65afa397'
            'ede43fdcdee6f53ba5110aa55a5996a3be36fe051698887ce311c26c86efacf8')

prepare() {
  cd "${srcdir}/${_realname}-${pkgver}"
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
    "${srcdir}/${_realname}-${pkgver}"
  make -j1
}

package() {
  cd "${srcdir}/build-${MINGW_CHOST}"
  make DESTDIR="${pkgdir}" install
  install -Dm644 -t "${pkgdir}${MINGW_PREFIX}/libexec/${_realname}" example/*.exe tool/*.exe benchmark/*.exe

  cd "${srcdir}/${_realname}-${pkgver}"
  install -Dm755 -t "${pkgdir}${MINGW_PREFIX}/share/doc/${_realname}" LICENSE README.md docs/*
}
