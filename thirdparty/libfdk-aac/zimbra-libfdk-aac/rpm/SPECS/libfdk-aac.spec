Summary:            Zimbra's FDK AAC codec build
Name:               zimbra-libfdk-aac
Version:            VERSION
Release:            ITERATIONZAPPEND
License:            CUSTOM
Source:             %{name}-%{version}.tar.gz
AutoReqProv:        no
URL:                https://sourceforge.net/projects/opencore-amr/

%description
Fraunhofer FDK AAC codec library

%define debug_package %{nil}

%prep
%setup -n fdk-aac-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
./autogen.sh
./configure --prefix=OZC \
--disable-static
make

%install
make install DESTDIR=${RPM_BUILD_ROOT}

%package devel
Summary:        libfdk-aac development pieces
Requires:       zimbra-libfdk-aac
AutoReqProv:    no

%description devel
libfdk-aac development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*

%files devel
%defattr(-,root,root)
OZCL/*.la
OZCL/*.so
OZCL/pkgconfig
OZCI

%changelog
* Wed Aug 5 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
