import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { workScheduler } from '@kit.BackgroundTasksKit';
const DOMAIN = 0xFFFF;
const TAG = 'EntryAbility'


const WEATHER_WORK_INFO: workScheduler.WorkInfo = {
  workId:1,
  abilityName: 'WeatherWorker',
  bundleName: 'com.hmosdemos.wearable.how_to_build_background_task_scheduler',
  networkType: workScheduler.NetworkType.NETWORK_TYPE_ANY,
  isPersisted: true,
  isRepeat: true,
  repeatCycleTime: 7200000
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'app is on foreground')
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'App is on background');
    workScheduler.stopAndClearWorks();
    try {
      workScheduler.stopWork(WEATHER_WORK_INFO, false);
      hilog.info(DOMAIN, TAG, 'Previous work stopped');
    } catch (e) {
      hilog.info(DOMAIN, TAG, 'No previous work to stop');
    }

    try {
      workScheduler.startWork(WEATHER_WORK_INFO);
      hilog.info(DOMAIN, TAG, 'Task registered successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `startwork error: ${error.code} - ${error.message}`);
    }
  }

}