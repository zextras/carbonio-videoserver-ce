Summary:            Zimbra's Opus codec build
Name:               zimbra-libopus
Version:            VERSION
Release:            ITERATION%{?dist}
License:            BSD
Source:             %{name}-%{version}.tar.gz
AutoReqProv:        no
URL:                https://www.webmproject.org/

%description
Totally open, royalty-free, highly versatile audio codec

%prep
%setup -n opus-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
./configure --prefix=OZC \
--disable-static \
--enable-custom-modes
make

%install
make install DESTDIR=${RPM_BUILD_ROOT}

%package devel
Summary:        opus development pieces
Requires:       zimbra-libopus
AutoReqProv:    no

%description devel
libopus development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/*.la
OZCL/pkgconfig
OZCI
OZCS

%changelog
* Wed Aug 5 2020 Zextras Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
