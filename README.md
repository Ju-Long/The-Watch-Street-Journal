<p align="center">
<img src="./Assets/logo.png" alt="The Watch Street Journal" title="The Watch Street Journal" width="600"/>
</p>

<p align="center">
<a href="https://apps.apple.com/us/app/the-watch-street-journal/id6450393866"><img src="./Assets/Download on the App Store.png" width="300"/></a>
</p>

TWSJ(The Watch Street Journal) is a fully open source application on the app store available for download on WatchOS. It does not use third party services except for Google News RSS which can be find available [here](https://news.google.com/)

## Functionalities

It uses locale provided from user device and find the most suitable country to fetch data from. Then it will send a request with the relevant country & language information and Google News will return the most related news from that country.

It provides a list of topics to choose from, then a request will be made to Google News with the selected topic and country.

It also allow user to select a list of countries and news will be fetched accordingly.

## Requirements

Apple Watch with WatchOS > 9.0

## Future of TWSJ

If you wish to contribute or suggest ideas that does not use third party services, feel free to leave a discussion or issue message. *note i'm not always around but will check back once in a while.

## Packages

- [King Fisher - Image Fetching & Caching](https://github.com/onevcat/Kingfisher)
- [Fuzi - XML & HTML Parser](https://github.com/cezheng/Fuzi)
- [Alamofire - HTTP Request](https://github.com/Alamofire/Alamofire)
- [SwiftyJSON - JSON Parser](https://github.com/SwiftyJSON/SwiftyJSON)