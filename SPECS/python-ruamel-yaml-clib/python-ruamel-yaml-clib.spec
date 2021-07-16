%global pypi_name ruamel.yaml.clib
%global pname ruamel-yaml-clib
Summary:        C version of reader, parser and emitter for ruamel.yaml derived from libyaml
Name:           python-%{pname}
Version:        0.1.2
Release:        7%{?dist}
License:        MIT
Vendor:         Microsoft Corporation
Distribution:   Mariner
URL:            https://pypi.org/project/ruamel.yaml.clib/
# Repository lives on https://sourceforge.net/projects/ruamel-yaml-clib/; however, the snapshot is an unreliable link
Source0:        https://files.pythonhosted.org/packages/6a/6c/7b461053ce5be0d7c8b12dcae9a7c10e8012238a00f6fcd98643ee66d2de/%{pypi_name}-%{version}.tar.gz
BuildRequires:  gcc
BuildRequires:  libyaml-devel

%description
It is the C based reader/scanner and emitter for ruamel.yaml.

%package -n     python3-%{pname}
Summary:        %{summary}
BuildRequires:  python3-Cython
BuildRequires:  python3-devel
BuildRequires:  python3-setuptools
Requires:       python3-setuptools
# This creates a cyclic dependency when installing. Comment out for now
#Requires:       python3-ruamel-yaml

%description -n python3-%{pname}
It is the C based reader/scanner and emitter for ruamel.yaml.

%prep
%autosetup -n %{pypi_name}-%{version}
# Force regenerating C files from Cython sources
# rm -v $(grep -rl '/\* Generated by Cython')

%build
# cython refuses to cythonize a file in a directory that cannot be a Python module ¯\_(ツ)_/¯
%py3_build

%install
python3 setup.py install --single-version-externally-managed --skip-build --root %{buildroot}

%files -n python3-%{pname}
%license LICENSE
%doc README.rst
%{python3_sitearch}/_ruamel_yaml.cpython-*
%{python3_sitearch}/%{pypi_name}-%{version}-py%{python3_version}.egg-info

%changelog
* Mon Jun 21 2021 Rachel Menge <rachelmenge@microsoft.com> - 0.1.2-7
- Initial CBL-Mariner version imported from Fedora 34 (license: MIT)
- Comment out requires python3-ruamel-yaml
- License verified

* Wed Jan 27 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.1.2-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Thu Nov 12 2020 Miro Hrončok <mhroncok@redhat.com> - 0.1.2-5
- Force regenerating C files from Cython sources
- Require python3-ruamel-yaml

* Wed Jul 29 2020 Fedora Release Engineering <releng@fedoraproject.org> - 0.1.2-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Tue May 26 2020 Miro Hrončok <mhroncok@redhat.com> - 0.1.2-3
- Rebuilt for Python 3.9

* Thu Jan 30 2020 Fedora Release Engineering <releng@fedoraproject.org> - 0.1.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Fri Aug 30 2019 Chandan Kumar <raukadah@gmail.com> - 0.1.2-1
- Initial package
