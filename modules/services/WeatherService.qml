pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    id: root

    // Current weather data
    property string weatherSymbol: ""
    property real currentTemp: 0
    property real maxTemp: 0
    property real minTemp: 0
    property int weatherCode: 0
    property real windSpeed: 0
    property bool dataAvailable: false

    // Internal state
    property int retryCount: 0
    property int maxRetries: 5
    property string cachedLat: ""
    property string cachedLon: ""

    function getWeatherCodeEmoji(code) {
        if (code === 0)
            return "☀️";
        if (code === 1)
            return "🌤️";
        if (code === 2)
            return "⛅";
        if (code === 3)
            return "☁️";
        if (code === 45)
            return "🌫️";
        if (code === 48)
            return "🌨️";
        if (code >= 51 && code <= 53)
            return "🌦️";
        if (code === 55)
            return "🌧️";
        if (code >= 56 && code <= 57)
            return "🧊";
        if (code >= 61 && code <= 65)
            return "🌧️";
        if (code >= 66 && code <= 67)
            return "🧊";
        if (code >= 71 && code <= 77)
            return "❄️";
        if (code >= 80 && code <= 81)
            return "🌦️";
        if (code === 82)
            return "🌧️";
        if (code >= 85 && code <= 86)
            return "🌨️";
        if (code === 95)
            return "⛈️";
        if (code >= 96 && code <= 99)
            return "🌩️";
        return "❓";
    }

    function convertTemp(temp) {
        if (Config.weather.unit === "F") {
            return (temp * 9 / 5) + 32;
        }
        return temp;
    }

    function fetchWeatherWithCoords(lat, lon) {
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current_weather=true&daily=temperature_2m_max,temperature_2m_min&timezone=auto";
        weatherProcess.command = ["curl", "-s", url];
        weatherProcess.running = true;
    }

    function urlEncode(str) {
        return str.replace(/%/g, "%25").replace(/ /g, "%20").replace(/!/g, "%21").replace(/"/g, "%22").replace(/#/g, "%23").replace(/\$/g, "%24").replace(/&/g, "%26").replace(/'/g, "%27").replace(/\(/g, "%28").replace(/\)/g, "%29").replace(/\*/g, "%2A").replace(/\+/g, "%2B").replace(/,/g, "%2C").replace(/\//g, "%2F").replace(/:/g, "%3A").replace(/;/g, "%3B").replace(/=/g, "%3D").replace(/\?/g, "%3F").replace(/@/g, "%40").replace(/\[/g, "%5B").replace(/]/g, "%5D");
    }

    function updateWeather() {
        var location = Config.weather.location.trim();
        if (location.length === 0) {
            geoipProcess.command = ["curl", "-s", "https://ipapi.co/json/"];
            geoipProcess.running = true;
            return;
        }

        var coords = location.split(",");
        var isCoordinates = coords.length === 2 && !isNaN(parseFloat(coords[0].trim())) && !isNaN(parseFloat(coords[1].trim()));

        if (isCoordinates) {
            cachedLat = coords[0].trim();
            cachedLon = coords[1].trim();
            fetchWeatherWithCoords(cachedLat, cachedLon);
        } else {
            var encodedCity = urlEncode(location);
            var geocodeUrl = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodedCity;
            geocodingProcess.command = ["curl", "-s", geocodeUrl];
            geocodingProcess.running = true;
        }
    }

    property Process geoipProcess: Process {
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.latitude && data.longitude) {
                            root.cachedLat = data.latitude.toString();
                            root.cachedLon = data.longitude.toString();
                            root.fetchWeatherWithCoords(root.cachedLat, root.cachedLon);
                        } else {
                            root.dataAvailable = false;
                        }
                    } catch (e) {
                        root.dataAvailable = false;
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                root.dataAvailable = false;
            }
        }
    }

    property Process geocodingProcess: Process {
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.results && data.results.length > 0) {
                            var result = data.results[0];
                            root.cachedLat = result.latitude.toString();
                            root.cachedLon = result.longitude.toString();
                            root.fetchWeatherWithCoords(root.cachedLat, root.cachedLon);
                        } else {
                            root.dataAvailable = false;
                        }
                    } catch (e) {
                        root.dataAvailable = false;
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                root.dataAvailable = false;
            }
        }
    }

    property Process weatherProcess: Process {
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.current_weather && data.daily) {
                            var weather = data.current_weather;
                            var daily = data.daily;
                            
                            root.weatherCode = parseInt(weather.weathercode);
                            root.currentTemp = convertTemp(parseFloat(weather.temperature));
                            root.windSpeed = parseFloat(weather.windspeed);
                            
                            // Get today's max/min temps
                            if (daily.temperature_2m_max && daily.temperature_2m_max.length > 0) {
                                root.maxTemp = convertTemp(parseFloat(daily.temperature_2m_max[0]));
                            }
                            if (daily.temperature_2m_min && daily.temperature_2m_min.length > 0) {
                                root.minTemp = convertTemp(parseFloat(daily.temperature_2m_min[0]));
                            }

                            root.weatherSymbol = getWeatherCodeEmoji(root.weatherCode);
                            root.dataAvailable = true;
                            root.retryCount = 0;
                        } else {
                            root.dataAvailable = false;
                            if (root.retryCount < root.maxRetries) {
                                root.retryCount++;
                                retryTimer.interval = Math.min(600000, 5000 * Math.pow(2, root.retryCount - 1));
                                retryTimer.start();
                            }
                        }
                    } catch (e) {
                        console.warn("WeatherService: JSON parse error:", e);
                        root.dataAvailable = false;
                        if (root.retryCount < root.maxRetries) {
                            root.retryCount++;
                            retryTimer.interval = Math.min(600000, 5000 * Math.pow(2, root.retryCount - 1));
                            retryTimer.start();
                        }
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                root.dataAvailable = false;
                if (root.retryCount < root.maxRetries) {
                    root.retryCount++;
                    retryTimer.interval = Math.min(600000, 5000 * Math.pow(2, root.retryCount - 1));
                    retryTimer.start();
                }
            }
        }
    }

    property Timer retryTimer: Timer {
        repeat: false
        running: false
        onTriggered: root.updateWeather()
    }

    property Timer refreshTimer: Timer {
        // Periodic weather refresh (every 10 minutes)
        interval: 600000
        running: true
        repeat: true
        onTriggered: root.updateWeather()
    }

    property Connections configConnections: Connections {
        target: Config.weather
        function onLocationChanged() {
            root.updateWeather();
        }
        function onUnitChanged() {
            root.updateWeather();
        }
    }

    Component.onCompleted: {
        updateWeather();
    }
}
