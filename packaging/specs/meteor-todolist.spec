Name: @@packagename@@
Version: @@version@@
RELEASE: @@versiontag@@
Summary: Meteor::TODOList
License: GPLv2
Vendor: Eugene Akhmetkhanov
URL: https://github.com/axmetishe/meteor-todolist
Group: Converted/contrib/misc
Packager: Eugene Akhmetkhanov
autoprov: yes
autoreq: yes
Prefix: /opt/meteor
BuildArch: x86_64

%description

%install

%files
%defattr(644,meteor,meteor,755)
 "/opt/meteor"
%dir %attr(644,meteor,meteor) "/var/log/meteor"
%config %attr(644,root,root)  "/lib/systemd/system/meteor.service"
