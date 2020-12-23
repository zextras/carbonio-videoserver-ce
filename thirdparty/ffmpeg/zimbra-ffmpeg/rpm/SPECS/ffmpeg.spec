Summary:            Zimbra's FFMPEG build
Name:               zimbra-ffmpeg
Version:            VERSION
Release:            1%{?dist}
License:            GPL3
Source:             %{name}-%{version}.tar.gz
BuildRequires:      freetype-devel
BuildRequires:      lame-devel
BuildRequires:      libass-devel
BuildRequires:      libtheora-devel
BuildRequires:      libxcb-devel
BuildRequires:      x264-devel
BuildRequires:      zimbra-libfdk-aac-devel
BuildRequires:      zimbra-libopus-devel
BuildRequires:      zimbra-libvpx-devel
BuildRequires:      zlib-devel
Requires:       freetype
Requires:       lame-libs
Requires:       libass
Requires:       libtheora
Requires:       libxcb
Requires:       x264-libs
Requires:       zimbra-libfdk-aac
Requires:       zimbra-libopus
Requires:       zimbra-libvpx
Requires:       zlib
AutoReqProv:        no
URL:                https://ffmpeg.org/

%description
Complete solution to record, convert and stream audio and video

%prep
%setup -n ffmpeg-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
PKG_CONFIG_PATH=OZCL/pkgconfig ./configure --prefix=OZC \
--disable-static \
--enable-shared \
--disable-debug \
--disable-stripping \
--extra-cflags="-IOZC/include" \
--extra-ldflags="-LOZC/lib" \
--bindir="OZC/bin" \
--enable-gpl \
--enable-libass \
--enable-libfdk-aac \
--enable-libfreetype \
--enable-libmp3lame \
--enable-libopus \
--enable-libtheora \
--enable-libvpx \
--enable-libx264 \
--enable-nonfree \
--enable-libxcb
make -j$(nproc)

%install
make install DESTDIR=${RPM_BUILD_ROOT}
rm -rf ${RPM_BUILD_ROOT}OZCS

%package devel
Summary:        ffmpeg development pieces
Requires:       zimbra-ffmpeg
AutoReqProv:    no

%description devel
ffmpeg development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*
OZCB

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/pkgconfig
OZCI

%changelog
* Wed Dec 23 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
