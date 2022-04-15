# Maintainer: Kingtous <me@kingtous.cn>
pkgname=fclash
pkgver=1.0.0
pkgrel=1
epoch=
pkgdesc="A Clash Proxy Fronted based on Clash"
arch=('x86_64')
url="https://github.com/kingtous/fclash"
license=('GPL-3.0')
groups=()
depends=('libappindicator-gtk3')
makedepends=(cmake gcc)
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("${pkgname%-git}::git+https://github.com/Kingtous/Fclash.git#branch=stable")
noextract=()
sha256sums=('SKIP')
validpgpkeys=()


build() {
	cd "${srcdir}/${pkgname%-git}"
    flutter config --enable-linux-desktop
    flutter pub get
	flutter build linux --release
}


package() {
    cp -r "${srcdir}/${pkgname%-git}/debian/build-src/opt"  "${pkgdir}/opt"
    cp -r "${srcdir}/${pkgname%-git}/build/linux/x64/release/bundle" "${pkgdir}/opt/apps/cn.kingtous.fclash/files"
	install -Dm0755 "${srcdir}/${pkgname%-git}/debian/build-src/opt/apps/cn.kingtous.fclash/entries/applications/cn.kingtous.service-monitor.desktop" "${pkgdir}/usr/share/applications/cn.kingtous.service-monitor.desktop"
}