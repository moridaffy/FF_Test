<h1 align="center">
  <br>
  FF
  <br>
</h1>

<h4 align="center">Тестовое задание для кандидатов в компании Family Friend</h4>

<h1 align="center">
<img src="https://raw.githubusercontent.com/moridaffy/FF_test/master/Extra/screenshot_list.png" alt="Список репозиториев" width="250"> <img src="https://raw.githubusercontent.com/moridaffy/FF_test/master/Extra/screenshot_details.png" alt="Детальная информация о репозитории" width="250">
</h1>

<p align="center">
  <a href="#Информация">Информация</a> •
  <a href="#Как-запустить">Как запустить</a> •
  <a href="#Разработчик">Разработчик</a>
</p>

## Информация
* Данные для списка загружаются при помощи GitHub API v3
* Несмотря на ошибку в стандартном API GitHub'a (кол-во watcher'ов отображается неправильно), в приложении все же отображается верная информация
* Приложение написано на Swift'e
* Верстка экранов соответствует предоставленному макету в Sketch
* Интерфейсы построены в IB с использованием AutoLayout'a
* Приложение использует 3 сторонних фреймворка: <a href="https://github.com/SwiftyJSON/SwiftyJSON">SwiftyJSON</a>, <a href="https://github.com/ninjaprox/NVActivityIndicatorView">NVActivityIndicatorView</a> и <a href="https://github.com/realm/realm-cocoa">Realm</a>
* Список обновляется при помощи жеста "pull to refresh"
* Соблюдены требования по поддерживаемой версии iOS, поддерживаемым устройствам и ориентации
* Загруженные данные сохраняются в локальный Realm, что позволяет просматривать их при последующем запуске приложения при отсутствии подключения к интернету


## Как запустить
Чтобы приложение начало работу после fork'a/загрузки, необходимо выполнить следующие действия:

* Перейдите в директорию проекта и запустите следующую команду для установки вспомогательных библиотек (необходимо наличие <a href="https://cocoapods.org" target="_blank">CocoaPods</a>):
```
pod install
```

## Разработчик
<a href="http://mskr.name">Веб-сайт</a>  
<a href="http://vk.com/morimax">ВК</a>  
<a href="http://t.me/moridaffy">Telegram</a>  
<a href="mailto:dev@mskr.name">E-Mail</a>
