package unity.plugin.sample;


import android.app.ActivityManager;
import android.content.Context;
import android.os.Debug;


public class MemorySample
{
	/**
	 * @return 現在使用しているメモリ容量、端末のRAM容量をJson形式で取得する(単位MB)
	 */
	public static  String GetNativeMemoryInfo(){

		//-----------------------------------------------------
		//VM情報を取得する
		//-----------------------------------------------------

		// メモリ情報を取得するための準備
		final Context context = UnityPlayer.currentActivity.getApplication().getApplicationContext();
		ActivityManager activityManager = (ActivityManager)context.getSystemService(context.ACTIVITY_SERVICE);
		ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
		activityManager.getMemoryInfo(memoryInfo);

		long totalMem = 0;    //端末に積まれているRAM容量を取得用

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
			//API Level16以上でないと使えない
			totalMem = memoryInfo.totalMem;

			//MBに変換する
			totalMem = (long)totalMem  / 1024 / 1024;
		}

		//dalvikとはAndroid用のJava仮想マシン
		//Java VMの情報を取得する
		int dalvikTotal = (int) (Runtime.getRuntime().totalMemory() / 1024 / 1024);
		int dalvikFree = (int) (Runtime.getRuntime().freeMemory() / 1024 / 1024);
		int javaMemory = dalvikTotal - dalvikFree; //javaMemoryの値がAndroid StudioのMonitorのメモリー表示される


		//-----------------------------------------------------
		//本プレセスのメモリの統計情報(マッピング情報)を取得する
		//-----------------------------------------------------

		//自分自身のプロセスIDを取得する
		final int[] pids = new int[]{ android.os.Process.myPid() };

		//メモリー情報を取得する
		//本家のコメント
		//Return information about the memory usage of one or more processes.
		final Debug.MemoryInfo[] memoryInfos = activityManager.getProcessMemoryInfo(pids);
		float sumMemories = 0;

		//本アプリが使用しているメモリ取得
		for (Debug.MemoryInfo m : memoryInfos) {

			//KB単位で取得する
			sumMemories += m.getTotalPss();

			Log.i("tag", " pidMemoryInfo.getTotalPrivateDirty(): " + m.getTotalPrivateDirty() + "\n");
			Log.i("tag", " pidMemoryInfo.getTotalPss(): " + m.getTotalPss() + "\n");
			Log.i("tag", " pidMemoryInfo.getTotalSharedDirty(): " + m.getTotalSharedDirty() + "\n");

			Log.i("tag", " pidMemoryInfo.dalvikPss: " + m.dalvikPss + "\n");
			Log.i("tag", " pidMemoryInfo.nativePss: " + m.nativePss + "\n");
			Log.i("tag", " pidMemoryInfo.otherPss: " + m.otherPss + "\n");
		}

		sumMemories = sumMemories / 1024;

		//json作成
		org.json.JSONObject json = new org.json.JSONObject();
		try{

			//端末に搭載されているRAM
			json.put("deviceRam",totalMem);

			//使用しているメモリの情報
			//dalvikPss  nativePss  otherPssの合計
			json.put("usageMemory",(int)sumMemories);

			//メモリ不足かのフラグ
			json.put("lowMemory",memoryInfo.lowMemory);

			//Android StudioのMonitorのメモリー表示の確認用
			json.put("javaMemory",javaMemory);


		}
		catch (Exception e){
			Log.e("tag", "json error e:" + e.toString());
		}


		Log.i("tag", json.toString());

		return json.toString();

	}

}
