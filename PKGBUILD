Maintainer: Kingtous <me@kingtous.cn>
pkgname=FClash
pkgver=1.0.0
pkgrel=1
epoch=
pkgdesc="A Clash Proxy Fronted based on Clash"
arch=('amd64')
url="https://github.com/kingtous/fclash"
license=('GPL-3.0')
groups=()
depends=('libappindicator-gtk3')
makedepends=('flutter')
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("$pkgname-$pkgver.tar.gz"
        "$pkgname-$pkgver.patch")
noextract=()
md5sums=()
validpgpkeys=()

prepare() {
	cd "$pkgname-$pkgver"
}

build() {
	cd "$pkgname-$pkgver"
	flutter build linux --release
	make
}

check() {
	cd "$pkgname-$pkgver"
	make -k check
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}