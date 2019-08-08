brew update
brew uninstall --ignore-dependencies libimobiledevice
brew uninstall --ignore-dependencies usbmuxd
brew install --HEAD usbmuxd
brew unlink usbmuxd & brew link usbmuxd
brew install --HEAD libimobiledevice
brew link --overwrite libimobiledevice
brew install ideviceinstaller
brew link --overwrite ideviceinstaller