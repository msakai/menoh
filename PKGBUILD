# Maintainer: Masahiro Sakai <masahiro.sakai@gmail.com>

_realname=menoh
_onnxversion=1.3.0
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=1.1.0
pkgrel=1
pkgdesc="Menoh - DNN inference library (mingw-w64)"
arch=('x86_64')
url='https://github.com/pfnet-research/menoh'
license=('MIT License')
depends=("${MINGW_PACKAGE_PREFIX}-mkl-dnn"
          "${MINGW_PACKAGE_PREFIX}-opencv")
makedepends=("${MINGW_PACKAGE_PREFIX}-gcc"
             "${MINGW_PACKAGE_PREFIX}-cmake"
             "${MINGW_PACKAGE_PREFIX}-mkl-dnn"
             "${MINGW_PACKAGE_PREFIX}-opencv")
options=('staticlibs' 'strip')
source=(${_realname}-${pkgver}.tar.gz::https://github.com/pfnet-research/menoh/archive/v${pkgver}.tar.gz
        onnx-${_onnxversion}.tar.gz::https://github.com/onnx/onnx/archive/v${_onnxversion}.tar.gz)
sha256sums=('62cbb4f9f992004da70acf4a842e0793b3944d44e629af07d8d592e7619bef99'
            '85a723d46f2ac53f823448ded5ab4af5c70414237d5253fabac93621ec19b043')

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
    -DLINK_STATIC_LIBPROTOBUF=ON \
    "${srcdir}/${_realname}-${pkgver}"
  make -j1
}

package() {
  cd "${srcdir}/build-${MINGW_CHOST}"
  make DESTDIR="${pkgdir}" install
  install -Dm644 -t "${pkgdir}${MINGW_PREFIX}/libexec/${_realname}" example/*.exe benchmark/*.exe

  cd "${srcdir}/${_realname}-${pkgver}"
  install -Dm755 -t "${pkgdir}${MINGW_PREFIX}/share/doc/${_realname}" LICENSE README.md docs/Doxyfile docs/DoxygenLayout.xml docs/LICENSE_THIRD_PARTY docs/*.md
  install -Dm755 -t "${pkgdir}${MINGW_PREFIX}/share/doc/${_realname}/image" docs/image/vgg16_view.png
}
