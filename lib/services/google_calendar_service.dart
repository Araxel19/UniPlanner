import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

class GoogleHttpClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}

Future<List<calendar.Event>> fetchGoogleCalendarEvents(String accessToken) async {
  final client = GoogleHttpClient(accessToken);
  final calendarApi = calendar.CalendarApi(client);

  final events = await calendarApi.events.list(
    "primary",
    maxResults: 10,
    singleEvents: true,
    orderBy: "startTime",
    timeMin: DateTime.now().toUtc(),
  );

  return events.items ?? [];
}