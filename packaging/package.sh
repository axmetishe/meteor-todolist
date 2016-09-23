#!/usr/bin/env bash
# Can be run with several commands:
# all - clean build directory, prepare sources, build rpm and deb
# clean - clean build directory
# rpm - clean build directory, prepare sources, build rpm
# deb - clean build directory, prepare sources, build deb

productName='meteor-todolist'
productVersion='1.0.0'
timestamp=$(date +%Y%m%d%H%M)

scriptDir=`dirname $(readlink -f $0)`
cd $scriptDir

buildDir="$(pwd)/target"

# $1 - build directory
cleanBuildDir() {
  [ -d $1 ] && rm -rf $1 || return 0
}

# $1 - build directory
rpm() {
  [ -n "$(which rpmbuild)" ]||{ echo "Please install rpmbuild!"; exit 1; }
  rpmbuild -bb --nodeps --noclean --buildroot=$1/BUILD/ -v $1/SPECS/$productName.spec --define "_rpmdir $1/RPMS"
  mv -t $1/dist/ $1/RPMS/x86_64/*.rpm

  if [ $? -eq 0 ] && ls $1/dist/*.rpm 1> /dev/null 2>&1; then
    echo "RPM package done, check '$1/dist'."
  fi
  return $?
}

# $1 - build directory
deb() {
  [ -n "$(which dpkg-deb)" ]||{ echo "Please install dpkg-deb!"; exit 1; }

  mv $1/SPECS/control $1/DEBIAN/
  mv $1/DEBIAN $1/BUILD/

  dpkg-deb --build $1/BUILD
  mv $1/BUILD.deb $1/$productName-$productVersion-$timestamp.deb
  mv -t $1/dist/ $1/*.deb

  if [ $? -eq 0 ] && ls $1/dist/*.deb 1> /dev/null 2>&1; then
    echo "DEB package done, check '$1/dist'."
  fi
  return $?
}

# $1 - build directory
# $2 - source directory
# $3 - product name
# $4 - product version
# $5 - version tag
prepareStructure() {
  cleanBuildDir $1

  mkdir -p $1/{SPECS,RPMS,DEBIAN,dist}
  mkdir -p $1/BUILD/{'opt/meteor','var/log/meteor'}

  cp -R -t $1/BUILD/opt/meteor/ ../target/bundle/*
  cp -t $1/SPECS/ $2/specs/*
  cp -t $1/DEBIAN/ $2/scripts/*
  chmod +x $1/DEBIAN/p*

  sed -i "s/@@packagename@@/$3/g" $1/SPECS/*
  sed -i "s/@@version@@/$4/g" $1/SPECS/*
  sed -i "s/@@versiontag@@/$5/g" $1/SPECS/*

  echo -e "\n%pre" >> $1/SPECS/$3.spec && cat $1/DEBIAN/preinst >> $1/SPECS/$3.spec
  echo -e "\n%post" >> $1/SPECS/$3.spec && cat $1/DEBIAN/postinst >> $1/SPECS/$3.spec
  echo -e "\n%postun" >> $1/SPECS/$3.spec && cat $1/DEBIAN/postrm >> $1/SPECS/$3.spec
}

case "$1" in
  all|"")
    prepareStructure $buildDir $scriptDir $productName $productVersion $timestamp
    rpm $buildDir
    deb $buildDir
    ;;
  rpm)
    prepareStructure $buildDir $scriptDir $productName $productVersion $timestamp
    rpm $buildDir
    ;;
  deb)
    prepareStructure $buildDir $scriptDir $productName $productVersion $timestamp
    deb $buildDir
    ;;
  clean)
    cleanBuildDir $buildDir
    ;;
  *)
    echo "Called with unknown argument '$1'" >&2
    echo "Usage: {all|rpm|deb|clean}" >&2
    exit 1
    ;;
esac

if [ "$?" -ne 0 ]; then
  echo "Something goes wrong, check output."
fi

exit $?
