package grafa.pomodoro

import android.os.Bundle
import android.content.Intent
import android.icu.util.Calendar
import android.provider.CalendarContract
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "grafa.pomodoro/calendar"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    GeneratedPluginRegistrant.registerWith(this)
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "insertToCalendar") {
        val text: String = call.argument("event")!!
        insertToCalendar(text)
        result.success(1)
      }
    }
  }

  fun insertToCalendar(event: String) {
    val parsed = JSONObject(event)

    val title = parsed["title"] as String
    val duration = parsed["duration"] as Int
    val startedAt = parsed["startedAt"] as String

    val calendar = Calendar.getInstance()
    val sdf = SimpleDateFormat("yyyy-MM-dd – kk:mm", Locale.ROOT)
    val date = sdf.parse(startedAt)
    calendar.time = date

    val intent = Intent(Intent.ACTION_INSERT)
            .setData(CalendarContract.Events.CONTENT_URI)
            .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, calendar.timeInMillis)
            .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, calendar.timeInMillis + duration * 60000)
            .putExtra(CalendarContract.Events.TITLE, title)
            .putExtra(CalendarContract.Events.DESCRIPTION, "This record is made by Pomodoro app by grafa.")
    startActivity(intent)
  }
}
