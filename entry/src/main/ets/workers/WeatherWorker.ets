import { WorkSchedulerExtensionAbility, workScheduler } from '@kit.BackgroundTasksKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';
import { taskpool } from '@kit.ArkTS';
import { WeatherResponse } from '../models/WeatherModel';

const TAG = 'WeatherWorker';
const DOMAIN = 0xFFFF;

const OPENWEATHER_API_KEY: string = 'YOUR_API_KEY';
const WEATHER_API_URL: string = `https://api.openweathermap.org/data/2.5/weather?q=Istanbul&appid=${OPENWEATHER_API_KEY}&units=metric`;

// Makes HTTP GET request to OpenWeatherMap API and returns the temperature value. Returns null on failure.
@Concurrent
async function fetchWeather(url: string): Promise<number | null> {
  const httpRequest = http.createHttp();
  try {
    const response = await httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      }
    );
    if (response.responseCode !== 200) {
      return null;
    }
    const rawData = JSON.parse(response.result as string) as WeatherResponse;
    return rawData.main.temp;
  }
  catch (e) {
    return e;
  } finally {
    httpRequest.destroy();
  }
}

export default class WeatherWorker extends WorkSchedulerExtensionAbility {
  // Triggered when a scheduled background work starts. Initiates the weather fetching process.
  async onWorkStart(work: workScheduler.WorkInfo): Promise<void> {
    hilog.info(DOMAIN, TAG, '== onworkstart triggered');
    hilog.info(DOMAIN, TAG, `workid: ${work.workId}`);
    try {
      await this.doFetchWeather();
    }
    catch (e) {
      hilog.error(DOMAIN, TAG, `Error ${e}`);
    }
  }

  /* Executes weather data fetching using taskpool for concurrent execution. 
  Handles the API call and processes the result. */
  async doFetchWeather(): Promise<void> {
    try {
      const task = new taskpool.Task(fetchWeather, WEATHER_API_URL, DOMAIN, TAG);
      const result = await taskpool.execute(task)
      hilog.debug(DOMAIN, TAG, `Taskpool result: ${result}`);
      const temperature = result as number | null;

      if (temperature !== null) {
        await this.saveTemperature(temperature);
        hilog.info(DOMAIN, TAG, 'Saved temperature successfully ')
      } else {
        hilog.error(DOMAIN, TAG, 'Failed to fetch weather data');
      }
    } catch (error) {

      hilog.error(DOMAIN, TAG, `Taskpool error: ${error.message}`);
    }
  }

  // Called when the background work is stopped or cancelled. Used for cleanup operations
  async onWorkStop(work: workScheduler.WorkInfo): Promise<void> {
    hilog.info(DOMAIN, TAG, `onWorkStop triggered`);
  }

  // Saves the fetched temperature and current timestamp to local preferences storage.
  private async saveTemperature(temperature: number): Promise<void> {
    const lastFetchTime: number = Date.now();
    try {
      const pref = await preferences.getPreferences(this.context, 'weather');
      await pref.put('temperature', `${temperature}`);
      await pref.put('lastFetchTime', `${lastFetchTime}`);
      await pref.flush();

      hilog.info(DOMAIN, TAG, `Weather: ${temperature}°C`);
      hilog.info(DOMAIN, TAG, `Saved - fetchtime: ${lastFetchTime}`);
    } catch (e) {
      hilog.error(DOMAIN, TAG, e);
    }

  }
}
