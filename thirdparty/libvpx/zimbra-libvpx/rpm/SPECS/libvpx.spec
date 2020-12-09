Summary:            Zimbra's VP8 and VP9 codec build
Name:               zimbra-libvpx
Version:            VERSION
Release:            1%{?dist}
License:            BSD
Source:             %{name}-%{version}.tar.gz
BuildRequires:      yasm
AutoReqProv:        no
URL:                https://www.webmproject.org/

%description
VP8 and VP9 codec

%prep
%setup -n libvpx-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
./configure --prefix=OZC \
--disable-install-docs \
--disable-install-srcs \
--enable-pic \
--enable-postproc \
--enable-runtime-cpu-detect \
--enable-shared \
--enable-vp8 \
--enable-vp9 \
--enable-vp9-highbitdepth \
--enable-vp9-temporal-denoising \
--as=yasm
make -j$(nproc)

%install
make install DIST_DIR=${RPM_BUILD_ROOT}OZC

%package devel
Summary:        libvpx development pieces
Requires:       zimbra-libvpx
AutoReqProv:    no

%description devel
libvpx development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*
OZCB

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/*.a
OZCL/pkgconfig
OZCI

%changelog
* Wed Aug 5 2020 Zextras SRL <packages@zextras.com>
- initial packaging
