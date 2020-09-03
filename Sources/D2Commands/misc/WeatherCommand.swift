import D2NetAPIs
import D2MessageIO

public class WeatherCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the weather for a city",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a city name!")
            return
        }

        OpenWeatherMapQuery(city: input).perform().listen {
            do {
                let weather = try $0.get()
                output.append(Embed(
                    title: ":white_sun_small_cloud: The weather for \(weather.name ?? input)",
                    description: weather.weather?.map { $0.description }.joined(separator: ", ").nilIfEmpty,
                    footer: weather.coord.map { Embed.Footer(text: "Latitude: \($0.lat) - longitude: \($0.lon)") },
                    fields: [
                        weather.main.map { Embed.Field(name: ":thermometer: Main", value: """
                            **Temperature:** \($0.temp)°C\($0.feelsLike.map { " (feels like \($0)°C)" } ?? "")
                            **Temperature min:** \($0.tempMin)°C
                            **Temperature max:** \($0.tempMax)°C
                            **Pressure:** \($0.pressure) hPa
                            **Humidity:** \($0.humidity)%
                            """) },
                        weather.wind.map { Embed.Field(name: ":wind_blowing_face: Wind", value: """
                            **Speed:** \($0.speed) m/s
                            **Direction:** \($0.deg)°
                            """) },
                        weather.clouds.map { Embed.Field(name: ":cloud: Clouds", value: """
                            **Cloudiness:** \($0.all)%
                            """) },
                        weather.rain.map { Embed.Field(name: ":droplet: Rain", value: """
                            **Last hour:** \($0.lastHour) mm
                            **Last 3 hours:** \($0.last3Hours) mm
                            """) },
                        weather.snow.map { Embed.Field(name: ":snowflake: Snow", value: """
                            **Last hour:** \($0.lastHour) mm
                            **Last 3 hours:** \($0.last3Hours) mm
                            """) },
                        weather.timezone.map { Embed.Field(name: ":earth_africa: Timezone", value: "UTC+\($0)") }
                    ].compactMap { $0 }
                ))
            } catch {
                output.append(error, errorText: "Could not fetch the weather")
            }
        }
    }
}
