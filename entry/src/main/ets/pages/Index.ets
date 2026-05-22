import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';

const DOMAIN = 0xFFFF;
const TAG = 'IndexPage';

@Entry
@ComponentV2
struct Index {
  @Local temperature: string = '--';
  @Local lastFetchTime: string = 'no fetch yet';

  // Read from preferences and update the UI with the latest fetched data
  async onPageShow() {
    try {
      const context = this.getUIContext().getHostContext();
      const storeName: string = 'weather';
      await preferences.removePreferencesFromCache(context, storeName);
      const storeOptions: preferences.Options = { name: storeName };
      const pref: preferences.Preferences = preferences.getPreferencesSync(context, storeOptions);
      const tempVal: preferences.ValueType = pref.getSync('temperature', '--');
      const timeVal: preferences.ValueType = pref.getSync('lastFetchTime', '--');
      this.temperature = tempVal.toString();
      this.lastFetchTime = timeVal.toString();
    } catch (error) {
      const err: Error = error as Error;
      hilog.error(DOMAIN, TAG,`Error loading weather data: ${err.message}`);
    }
  }

  build() {
    Column() {
      Text($r('app.string.weather_title'))
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .onAppear(() => {
          hilog.debug(DOMAIN, TAG, `temperature = @@@MATH_INLINE_0_END@@@{this.lastFetchTime} `)
        })

      Text(this.temperature === '0' ? $r('app.string.default_temperature') : `${this.temperature}${$r('app.string.temperature_unit')}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 })

      Text(this.getWeatherEmoji())
        .fontSize(24)
        .margin({ top: 2 })

      Text(this.getWeatherDescription())
        .fontSize(11)
        .fontColor($r('app.color.gray40'))

      Divider().margin({ top: 8, bottom: 8 })

      Text(`${$r('app.string.last_updated_label')}${this.formatTime()}`)
        .fontSize(10)
        .fontColor($r('app.color.gray60'))

      Text($r('app.string.background_refresh_label'))
        .fontSize(10)
        .fontColor($r('app.color.gray60'))
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(8)
  }

  private getTemperatureNumber(): number | null {
    if (this.temperature === '--' || this.temperature === '0') {
      return null;
    }
    const temp = parseFloat(this.temperature);
    return isNaN(temp) ? null : temp;
  }

  getWeatherEmoji(): string {
    const temp = this.getTemperatureNumber();

    if (temp === null) {return '🌤️'};
    if (temp > 25) {return '☀️'};
    if (temp > 15) {return '⛅'};
    if (temp > 5) {return '🌧️'};
    return '❄️';
  }

  private getWeatherDescription(): Resource {
    const temp = this.getTemperatureNumber();

    if (temp === null) {return $r('app.string.no_data')};
    if (temp > 25) {return $r('app.string.hot_description')};
    if (temp > 15) {return $r('app.string.mild_description')};
    if (temp > 5) {return $r('app.string.cold_description')};
    return $r('app.string.very_cold_description');
  }

  private formatTime(): Resource | string {
    if (!this.lastFetchTime) {
      return $r('app.string.default_time');
    }

    let timestamp = Number.parseInt(this.lastFetchTime);
    if (!Number.isNaN(timestamp)) {
      let date = new Date(timestamp);
      let hours = date.getHours().toString().padStart(2, '0');
      let minutes = date.getMinutes().toString().padStart(2, '0');
      let seconds = date.getSeconds().toString().padStart(2, '0');
      return `${hours}:${minutes}:${seconds}`;
    }

    return this.lastFetchTime;
  }
}
