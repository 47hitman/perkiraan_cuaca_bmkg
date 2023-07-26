# Weather App using BMKG API

## Description
This is a weather app that utilizes the BMKG API (https://ibnux.github.io/BMKG-importer/) to fetch weather data and the API (https://ibnux.github.io/BMKG-importer/cuaca/wilayah.json) to get the region codes. The app provides weather forecasts based on the data received from BMKG. It uses the following packages as dependencies:

- http: ^1.1.0
- geolocator: ^9.0.2
- permission_handler: ^10.2.0
- intl: ^0.18.1
- dropdown_search: ^0.5.0
- loading_indicator 3.1.1
  
<img src="https://cdn.discordapp.com/attachments/1055490015834157058/1133654537748615198/Screenshot_1690354569.png" alt="Image" width="400" height="auto">

## Features
- Fetches weather data from the BMKG API based on selected regions or the user's current location.
- Displays weather forecasts for the selected region or the user's current location.
- Utilizes dropdown_search to allow users to search for regions based on city names.
- Uses geolocator to access the user's current location and display the weather for that location.

## How to Use the App
1. Clone the repository to your local machine.
2. Make sure you have Flutter installed on your system.
3. Run `flutter pub get` to get all the required dependencies.
4. Connect your device (physical or emulator) to the development machine.
5. Run the app using `flutter run`.

## Dependencies
The app uses several packages to handle specific functionalities:

- `http: ^1.1.0`: Used for making HTTP requests to the BMKG API and fetching weather data.
- `geolocator: ^9.0.2`: Allows the app to access the device's geolocation and obtain the user's current location.
- `permission_handler: ^10.2.0`: Handles asking for runtime permissions (e.g., location permission) from the user.
- `intl: ^0.18.1`: Provides internationalization and localization support for the app.
- `dropdown_search: ^0.5.0`: Enables the dropdown search functionality to find regions based on city names.

## Note
Please ensure that your device has an active internet connection to fetch the latest weather data from the BMKG API. Additionally, grant the necessary permissions for the app to access your device's location if you wish to see weather data for your current location.


