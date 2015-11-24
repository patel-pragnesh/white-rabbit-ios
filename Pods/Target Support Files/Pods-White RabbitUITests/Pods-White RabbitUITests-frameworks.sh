#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  else
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  fi

  local destination="${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi

  # use filter instead of exclude so missing patterns dont' throw errors
  echo "rsync -av --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync -av --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries
  local basename
  basename="$(basename "$1" | sed -E s/\\..+// && exit ${PIPESTATUS[0]})"
  local swift_runtime_libs
  swift_runtime_libs=$(xcrun otool -LX "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/${basename}.framework/${basename}" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u  && exit ${PIPESTATUS[0]})
  for lib in $swift_runtime_libs; do
    echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
    rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
    code_sign_if_enabled "${destination}/${lib}"
  done
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    echo "/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements \"$1\""
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$1"
  fi
}


if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework 'Pods-White RabbitUITests/AFNetworking.framework'
  install_framework 'Pods-White RabbitUITests/ALCameraViewController.framework'
  install_framework 'Pods-White RabbitUITests/BTNavigationDropdownMenu.framework'
  install_framework 'Pods-White RabbitUITests/Bolts.framework'
  install_framework 'Pods-White RabbitUITests/CLImageEditor.framework'
  install_framework 'Pods-White RabbitUITests/ContentfulDeliveryAPI.framework'
  install_framework 'Pods-White RabbitUITests/Dodo.framework'
  install_framework 'Pods-White RabbitUITests/Dollar.framework'
  install_framework 'Pods-White RabbitUITests/DynamicColor.framework'
  install_framework 'Pods-White RabbitUITests/Eureka.framework'
  install_framework 'Pods-White RabbitUITests/FBSDKCoreKit.framework'
  install_framework 'Pods-White RabbitUITests/FBSDKLoginKit.framework'
  install_framework 'Pods-White RabbitUITests/FillableLoaders.framework'
  install_framework 'Pods-White RabbitUITests/ISO8601DateFormatter.framework'
  install_framework 'Pods-White RabbitUITests/InstagramKit.framework'
  install_framework 'Pods-White RabbitUITests/MMMarkdown.framework'
  install_framework 'Pods-White RabbitUITests/Parse.framework'
  install_framework 'Pods-White RabbitUITests/ParseFacebookUtilsV4.framework'
  install_framework 'Pods-White RabbitUITests/ParseUI.framework'
  install_framework 'Pods-White RabbitUITests/SlideMenuControllerSwift.framework'
  install_framework 'Pods-White RabbitUITests/TagListView.framework'
  install_framework 'Pods-White RabbitUITests/Timepiece.framework'
  install_framework 'Pods-White RabbitUITests/XLPagerTabStrip.framework'
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework 'Pods-White RabbitUITests/AFNetworking.framework'
  install_framework 'Pods-White RabbitUITests/ALCameraViewController.framework'
  install_framework 'Pods-White RabbitUITests/BTNavigationDropdownMenu.framework'
  install_framework 'Pods-White RabbitUITests/Bolts.framework'
  install_framework 'Pods-White RabbitUITests/CLImageEditor.framework'
  install_framework 'Pods-White RabbitUITests/ContentfulDeliveryAPI.framework'
  install_framework 'Pods-White RabbitUITests/Dodo.framework'
  install_framework 'Pods-White RabbitUITests/Dollar.framework'
  install_framework 'Pods-White RabbitUITests/DynamicColor.framework'
  install_framework 'Pods-White RabbitUITests/Eureka.framework'
  install_framework 'Pods-White RabbitUITests/FBSDKCoreKit.framework'
  install_framework 'Pods-White RabbitUITests/FBSDKLoginKit.framework'
  install_framework 'Pods-White RabbitUITests/FillableLoaders.framework'
  install_framework 'Pods-White RabbitUITests/ISO8601DateFormatter.framework'
  install_framework 'Pods-White RabbitUITests/InstagramKit.framework'
  install_framework 'Pods-White RabbitUITests/MMMarkdown.framework'
  install_framework 'Pods-White RabbitUITests/Parse.framework'
  install_framework 'Pods-White RabbitUITests/ParseFacebookUtilsV4.framework'
  install_framework 'Pods-White RabbitUITests/ParseUI.framework'
  install_framework 'Pods-White RabbitUITests/SlideMenuControllerSwift.framework'
  install_framework 'Pods-White RabbitUITests/TagListView.framework'
  install_framework 'Pods-White RabbitUITests/Timepiece.framework'
  install_framework 'Pods-White RabbitUITests/XLPagerTabStrip.framework'
fi
