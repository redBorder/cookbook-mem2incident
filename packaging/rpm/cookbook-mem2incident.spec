%global cookbook_path /var/chef/cookbooks/mem2incident

Name: cookbook-mem2incident
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Redborder cookbook to install and configure redborder-mem2incident

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-mem2incident
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}%{cookbook_path}
cp -f -r  resources/* %{buildroot}%{cookbook_path}
chmod -R 0755 %{buildroot}%{cookbook_path}
install -D -m 0644 README.md %{buildroot}%{cookbook_path}/README.md

%pre
if [ -d /var/chef/cookbooks/mem2incident ]; then
    rm -rf /var/chef/cookbooks/mem2incident
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload mem2incident'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/mem2incident ]; then
  rm -rf /var/chef/cookbooks/mem2incident
fi

%files
%defattr(0644,root,root)
%attr(0755,root,root)
%{cookbook_path}
%defattr(0644,root,root)
%{cookbook_path}/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Fri Jun 28 2024 Miguel Negrón <manegron@redborder.com>
- first spec version