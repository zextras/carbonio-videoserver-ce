Summary:            Zimbra's libnice build
Name:               zimbra-libnice
Version:            VERSION
Release:            ITERATION%{?dist}
License:            BSD
Source:             %{name}-%{version}.tar.gz
BuildRequires:      openssl-devel
BuildRequires:      python3-pip
BuildRequires:      python3-setuptools
BuildRequires:      ninja-build
Requires:           openssl
AutoReqProv:        no
URL:                https://github.com/libnice/libnice

%description
An implementation of the IETF's draft ICE (for p2p UDP data streams)

%prep
%setup -n libnice-%{version}

%build
PKG_CONFIG_PATH=OZCL/pkgconfig \
meson --werror --warnlevel 2 -Dgtk_doc=disabled --prefix=OZC build --libdir=lib
meson compile -C build

%install
DESTDIR=${RPM_BUILD_ROOT} meson install -C build/

%package devel
Summary:        libnice development pieces
Requires:       zimbra-libnice
AutoReqProv:    no

%description devel
libnice development pieces

%files
%defattr(-,root,root)
OZCL/libnice.so.*
OZCB

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/pkgconfig
OZCI

%changelog
* Wed Aug 5 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
