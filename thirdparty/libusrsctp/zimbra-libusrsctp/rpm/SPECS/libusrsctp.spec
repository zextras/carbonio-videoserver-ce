Summary:            Zimbra's libusrsctp build
Name:               zimbra-libusrsctp
Version:            VERSION
Release:            ITERATIONZAPPEND
License:            BSD
Source:             %{name}-%{version}.tar.gz
AutoReqProv:        no
URL:                https://github.com/sctplab/usrsctp

%description
A portable SCTP userland stack

%define debug_package %{nil}

%prep
%setup -n usrsctp-3df8f52f44d6a24407112123aa68c6a24e8158f3

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
./bootstrap
./configure --prefix=OZC \
--disable-debug
make

%install
make install DESTDIR=${RPM_BUILD_ROOT}

%package devel
Summary:        libusrsctp development pieces
Requires:       zimbra-libusrsctp
AutoReqProv:    no

%description devel
libusrsctp development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*

%files devel
%defattr(-,root,root)
OZCL/*.a
OZCL/*.la
OZCL/*.so
OZCI

%changelog
* Wed Aug 5 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
