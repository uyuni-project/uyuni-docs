#
# spec file for package uyuni-docs_en
#
# Copyright (c) 2020 SUSE LLC.
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


%define htdocs /srv/www/htdocs/docs
%define apacheconfdir %{_sysconfdir}/apache2

Name:           uyuni-docs_en
Version:        2020.07
Release:        0
Provides:       locale(desktop-data-SLE:en)
Source0:        uyuni-docs_en.tar.gz
Source1:        uyuni-docs_en-pdf.tar.gz
Source2:        zz-uyuni-docs.conf
BuildRequires:  fdupes
BuildRequires:  filesystem
Requires:       filesystem
Requires:       release-notes-uyuni
BuildArch:      noarch
Obsoletes:      susemanager-jsp_en < %{version}
Provides:       susemanager-jsp_en = %{version}
Obsoletes:      susemanager-docs_en < %{version}
Provides:       susemanager-docs_en = %{version}
Summary:        Uyuni Documentation (English, HTML)
License:        GFDL-1.2-only
Group:          Documentation/SUSE
Url:            http://doc.opensuse.org

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
Provides:       susemanager-reference_en-pdf = %{version}
Obsoletes:      susemanager-reference_en-pdf < %{version}
Provides:       susemanager-best-practices_en-pdf = %{version}
Obsoletes:      susemanager-best-practices_en-pdf < %{version}
Provides:       susemanager-advanced-topics_en-pdf = %{version}
Obsoletes:      susemanager-advanced-topics_en-pdf < %{version}

%description -n uyuni-docs_en-pdf
Uyuni Documentation (English, PDF)

%prep
%setup -c -q -n %{name}-%{version}
%setup -T -D -a 1 -c -q -n %{name}-%{version}

%build

%install
mkdir -p %{buildroot}%{htdocs}
cp -r build/* %{buildroot}%{htdocs}
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
cp %{S:2} %{buildroot}%{apacheconfdir}/conf.d

%files -f nonpdf.filelist
%defattr(644, root, root)
%dir %{htdocs}
%exclude %{htdocs}/pdf
%config(noreplace) %{apacheconfdir}

%files -n uyuni-docs_en-pdf
%defattr(644, root, root)
%dir %{htdocs}/pdf
%{htdocs}/pdf/*

%changelog
