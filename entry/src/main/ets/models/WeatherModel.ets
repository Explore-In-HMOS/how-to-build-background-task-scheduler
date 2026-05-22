export class WeatherInfo {
  id: number = 0;
  main: string = '';
  description: string = '';
  icon: string = '';
}

export class MainData {
  temp: number = 0;
  feelsLike: number = 0;
  tempMin: number = 0;
  tempMax: number = 0;
  pressure: number = 0;
  humidity: number = 0;
  seaLevel: number = 0;
  grndLevel: number = 0;
}

export class WindData {
  speed: number = 0;
  deg: number = 0;
  gust?: number;
}

export class Clouds {
  all: number = 0;
}

export class Sys {
  type: number = 0;
  id: number = 0;
  country: string = '';
  sunrise: number = 0;
  sunset: number = 0;
}


export class Coord {
  lon: number = 0;
  lat: number = 0;
}


export class WeatherResponse {
  coord: Coord = { lon: 0, lat: 0 };
  weather: WeatherInfo[] = [];
  base: string = '';
  main: MainData = new MainData();
  visibility: number = 0;
  wind: WindData = new WindData();
  clouds: Clouds = new Clouds();
  dt: number = 0;
  sys: Sys = new Sys();
  timezone: number = 0;
  id: number = 0;
  name: string = '';
  cod: number = 0;
}
