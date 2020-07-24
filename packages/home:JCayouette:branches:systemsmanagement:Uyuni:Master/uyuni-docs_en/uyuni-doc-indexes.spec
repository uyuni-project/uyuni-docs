#
# spec file for package uyuni-doc-indexes
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

Name:           uyuni-doc-indexes
Version:        2020.07
Release:        0
Provides:       locale(desktop-data-SLE:en)
Source0:        nutch-conf.tar.bz2
Source1:        uyuni-doc-indexes-rpmlintrc
BuildRequires:  fdupes
BuildRequires:  filesystem
BuildRequires:  nutch-core
BuildRequires:  python
BuildRequires:  release-notes-uyuni
BuildRequires:  uyuni-docs_en
BuildRequires:  xerces-j2
Requires:       filesystem
Requires:       nutch-core
Requires:       release-notes-uyuni
Requires:       uyuni-docs_en = %{version}
Provides:       doc-indexes = %{version}
Provides:       spacewalk-doc-indexes = %{version}
Obsoletes:      spacewalk-doc-indexes < 4.1
BuildArch:      noarch
Obsoletes:      susemanager-jsp_en < %{version}
Provides:       susemanager-jsp_en = %{version}
Summary:        Uyuni Documentation Search Index
License:        Apache-2.0
Group:          Documentation/SUSE
Url:            http://doc.opensuse.org

%description -n uyuni-doc-indexes
Uyuni Documentation Search Index used for Web UI search functionality

%prep
%setup -c -q -n %{name}-%{version}

%build

%install
###################################################################
### generate search index                                       ###
###################################################################

cd %{_builddir}/%{name}-%{version}

# keep same level - different level might crash lucene
echo "file:///srv/www/htdocs/docs/" >> conf/urls/urls.txt

export HADOOP_HEAPSIZE=2000
export NUTCH_HOME=/usr/share/nutch-core

export URLS_DIR=`pwd`/conf/urls
export NUTCH_CONF_DIR=`pwd`/conf/nutch_conf
export NUTCH_OPTS=
export NUTCH_LOG_DIR=`pwd`/logs/
export OUTPUT_DIR=`pwd`/crawl_output/

echo "NUTCH_HOME = ${NUTCH_HOME}"
echo "NUTCH_CONF_DIR = ${NUTCH_CONF_DIR}"
echo "NUTCH_OPTS = ${NUTCH_OPTS}"
echo "NUTCH_LOG_DIR = ${NUTCH_LOG_DIR}"
echo "OUTPUT_DIR = ${OUTPUT_DIR}"

if [ ! -d ${OUTPUT_DIR} ]; then
    echo "Creating output directory ${OUTPUT_DIR}"
    mkdir -p ${OUTPUT_DIR}
fi

if [ ! -d ${NUTCH_LOG_DIR} ]; then
    echo "Creating output directory ${NUTCH_LOG_DIR}"
    mkdir -p ${NUTCH_LOG_DIR}
fi

if [ ! -d ${NUTCH_LOG_DIR} ]; then
    echo "Creating output directory ${NUTCH_LOG_DIR}"
    mkdir -p ${NUTCH_LOG_DIR}
fi

${NUTCH_HOME}/bin/nutch crawl ${URLS_DIR} -dir ${OUTPUT_DIR} 2>&1 | tee ${NUTCH_LOG_DIR}/crawl.log

install -d -m 755 %{buildroot}/%{_datadir}/rhn/search/indexes/docs/en-US/segments
cp -a $OUTPUT_DIR/index/* $RPM_BUILD_ROOT/%{_datadir}/rhn/search/indexes/docs/en-US || cat ${NUTCH_LOG_DIR}/hadoop.log
cp -a $OUTPUT_DIR/segments/* $RPM_BUILD_ROOT/%{_datadir}/rhn/search/indexes/docs/en-US/segments

%files 
%{_prefix}/share/rhn/search/indexes/docs
%dir %{_prefix}/share/rhn
%dir %{_prefix}/share/rhn/search
%dir %{_prefix}/share/rhn/search/indexes
%license conf/licenses/*

%changelog
