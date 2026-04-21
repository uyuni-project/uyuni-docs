#
# spec file for package uyuni-docs_en
#
# Copyright (c) 2026 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


%global susemanager_shared_path %{_datadir}/susemanager
%global wwwroot %{susemanager_shared_path}/www
%define www_path %{wwwroot}/htdocs
%define htdocs %{www_path}/docs
%if 0%{?suse_version}
%define apacheconfdir %{_sysconfdir}/apache2
%else
%define apacheconfdir %{_sysconfdir}/httpd
%endif
Name:           uyuni-docs_en
Version:        2026.04
Release:        0
Summary:        Uyuni Documentation (English, HTML)
License:        GFDL-1.2-only
Group:          Documentation/SUSE
URL:            https://www.uyuni-project.org/
Source0:        uyuni-docs_en.tar.gz
Source1:        uyuni-docs_en-pdf.tar.gz
Source2:        zz-uyuni-docs.conf
Source3:        reportdb-schema-docs.tar.xz
BuildRequires:  fdupes
BuildRequires:  filesystem
Requires:       filesystem
Requires:       release-notes-uyuni
Obsoletes:      susemanager-docs_en < %{version}
Provides:       susemanager-docs_en = %{version}
Provides:       locale(desktop-data-SLE:en)
Obsoletes:      uyuni-doc-indexes < %{version}-%{release}
BuildArch:      noarch

%description
Uyuni Documentation (English, HTML)

%package -n uyuni-docs_en-pdf
Summary:        Uyuni Getting Started (English, PDF)
Group:          Documentation/SUSE
BuildRequires:  filesystem
Requires:       filesystem
Requires:       uyuni-docs_en = %{version}
Provides:       susemanager-getting-started_en-pdf = %{version}
Obsoletes:      susemanager-getting-started_en-pdf < %{version}
Obsoletes:      susemanager-jsp_en < %{version}
Provides:       susemanager-jsp_en = %{version}
Provides:       susemanager-reference_en-pdf = %{version}
Obsoletes:      susemanager-reference_en-pdf < %{version}
Provides:       susemanager-best-practices_en-pdf = %{version}
Obsoletes:      susemanager-best-practices_en-pdf < %{version}
Provides:       susemanager-advanced-topics_en-pdf = %{version}
Obsoletes:      susemanager-advanced-topics_en-pdf < %{version}

%description -n uyuni-docs_en-pdf
Uyuni Documentation (English, PDF)

%prep
%setup -q -c
%setup -q -T -D -a 1 -c
%setup -q -T -D -a 3 -c

%build


%install
mkdir -p %{buildroot}%{htdocs}
cp -r build/* %{buildroot}%{htdocs}
cp -r reportdb-schema %{buildroot}%{htdocs}/en/
%fdupes '%{buildroot}%{htdocs}'
cd %{buildroot}
# Write the list of directories for main package, excluding pdf directory
find .%{htdocs}/* -type d -not -path ".%{htdocs}/pdf" -printf "%p\n" > %{_builddir}/%{name}-%{version}/nonpdf.filelist
sed -i -e 's/^\./\%dir /g' %{_builddir}/%{name}-%{version}/nonpdf.filelist
# Write the list of files for main package, excluding files from pdf directory
find .%{htdocs}/* -type f -not -path ".%{htdocs}/pdf/*" -printf "%p\n" >> %{_builddir}/%{name}-%{version}/nonpdf.filelist
sed -i -e 's/^\.//g' %{_builddir}/%{name}-%{version}/nonpdf.filelist

# Apache configuration
mkdir -p %{buildroot}%{apacheconfdir}/conf.d
sed 's#/srv/www/htdocs/docs#%{htdocs}#' %{SOURCE2} > %{buildroot}%{apacheconfdir}/conf.d/$(basename %{SOURCE2})

%files -f nonpdf.filelist
%defattr(644, root, root)
%dir %{susemanager_shared_path}
%dir %{wwwroot}
%dir %{www_path}
%dir %{htdocs}
%dir %{htdocs}/en
%exclude %{htdocs}/en/pdf
%config %{apacheconfdir}

%files -n uyuni-docs_en-pdf
%defattr(644, root, root)
%dir %{htdocs}/en/pdf
%{htdocs}/en/pdf/*

%changelog
