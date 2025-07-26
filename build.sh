#!/bin/bash
set -e
cd workdir

sync() {
  repo init --depth=1 -u https://github.com/rducks/android.git -b lineage-17.1

  git clone https://github.com/rducks/rom rom
  mv rom/q/los.xml .repo/local_manifests/roomservice.xml

  repo sync -j$(nproc --all) -c --force-sync --no-clone-bundle --no-tags --prune
  
  cd packages/apps/LineageParts
  rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml
  curl -sL https://raw.githubusercontent.com/AXP-OS/build/refs/heads/axp/Patches/LineageOS-17.1/android_packages_apps_LineageParts/0001-Remove_Analytics.patch | git apply --verbose -
  cd ../../..
  echo "LineageParts patch done!"

  cd packages/apps/SetupWizard
  curl -sL https://raw.githubusercontent.com/AXP-OS/build/refs/heads/axp/Patches/LineageOS-17.1/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch | git apply --verbose -
  cd ../../..
  echo "SetupWizard patch done!"

  rm -rf vendor/lineage/overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml

  for patch in rom/q/{0001,0002,0003,0004,0005,0006,0007}*; do
  patch -p1 < "$patch"
  done
}

build() {
  source build/envsetup.sh
  lunch lineage_RMX2185-user
  mka bacon -j$(nproc --all)
}

case "$1" in
  sync)
    sync;;
  build)
    build;;
  *)
    echo "Usage: $0 [sync|build]"
    exit 1;;
esac