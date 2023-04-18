# YTPull
Simple macOS App for downloading YouTube videos and audio, powered with SwiftUI and Combine.

**YTPull** is a free and open source macOS application that lets you download YouTube videos and audio using SwiftUI and Combine. It provides a modern and responsive UI, advanced downloading capabilities, and seamless integration with macOS technologies. With **YTPull**, you can easily grab your favorite YouTube media for offline use or other purposes.

## Features
- [ ] Download videos from Youtube URL. 
- [ ] Download videos from playlists or channels.
- [x] Extract and export best audio from video.
- [ ] Auto copy/paste Youtube URL.

## Installation
There are multiple ways to install the app.

### Download the App
The easiest way to install **YTPull** is.
1. Download the latest release as an app.
2. Unzip the download by double-click on it.

Notes: In case you don't see **YTPull** appear on your status bar. Let's continue to more `YTPull.app` into the `Applications` folder.

### Homebrew Cask
You can also install **YTPull** using Homebrew Cask, a package manager for macOS:
1. Install Homebrew (if not already installed)

Open a terminal window on your macOS device.
Enter the following command and press Enter to install Homebrew if you haven't installed it already:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Follow the on-screen prompts to complete the installation of Homebrew.

2. Install **YTPull** with Homebrew Cask

In the same terminal window, enter the following command and press Enter to install **YTPull** using Homebrew Cask:
```
brew install --cask ytpull
```
Homebrew Cask will download and install **YTPull** on your macOS device.

3. Launch **YTPull**

After the installation is complete, you can launch **YTPull** by searching for it in the Applications folder or by typing "YTPull" in Spotlight (Cmd + Space) and hitting Enter.

### Build from Source
**Xcode 14 and Swift 5 is required**
You can build **YTPull** directly on your machine:
1. Clone the **YTPull** repository
```
git clone git@github.com:huynguyen-n/YTPull.git
```
2. Open the `YTPull.xcodeproj` and hit ***Build*** and ***Run***. Make sure that the ***YTPull*** scheme is selected.

## Contributing
Thank you for your interest in contributing to **YTPull**. You can contribute by fixing bugs, adding new features, improving documentation, testing, or enhancing UX/UI. Your contributions will help make **YTPull** even better. Join us and be a part of our community!

## Acknowledgements
[yt-dlp](https://github.com/yt-dlp/yt-dlp)

Thank you for your open-source project that has been instrumental in helping me build **YTPull**. Your dedication and hard work are greatly appreciated!

## FAQ
### What is **YTPull**?
**YTPull** is a macOS application for downloading YouTube videos and audio. It is an open-source project that uses SwiftUI and Combine to provide a user-friendly interface and seamless YouTube downloading experience.

### Is **YTPull** free to use?
Yes, **YTPull** is completely free to use. It is an open-source project and does not charge any fees for downloading videos or audio from YouTube.

### Can I contribute to **YTPull**?
Yes, **YTPull** welcomes contributions from the open-source community. You can contribute by fixing bugs, adding new features, improving documentation, testing, or enhancing UX/UI. Please refer to the contribution guidelines and code of conduct for more information.

### Is **YTPull** safe to use?
**YTPull** is an open-source project and is built with a focus on security and user privacy. However, as with any software, it is recommended to use it responsibly and ensure that you are downloading videos and audio from YouTube in compliance with their terms of service and applicable laws.

## Donation
**YTPull** is free for you to use. I work on the app in my spare time. If you would like to support the development by donating, you can do so.

<a href='https://ko-fi.com/K3K0KATVS' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a> <a href='https://paypal.me/huynguyen1012' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://raw.githubusercontent.com/huynguyen-n/donation-buttons/main/donate-with-Paypal.svg' border='0' alt='Donate with Paypal' /></a>


**Thank you for being a part of the **YTPull** community and supporting my open-source project!**