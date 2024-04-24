import 'package:flutter/material.dart';
import 'package:dailyspace/custom_classes/taskinfo.dart';
import 'package:intl/intl.dart';

class Calendar extends StatelessWidget {
  final Map<String, TaskInfo>? availableActivities;

  const Calendar({Key? key, this.availableActivities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, TaskInfo> activities = availableActivities ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Activities'),
        backgroundColor: Colors.blue,
      ),
      body: activities.isEmpty
          ? Center(child: Text('No activities available'))
          : buildActivitiesTimeline(activities),
    );
  }

  Widget buildActivitiesTimeline(Map<String, TaskInfo> activities) {
    List<Widget> timelineTasks = [];
    for (int hour = 0; hour < 24; hour++) {
      List<TaskInfo> hourlyTasks = activities.values
          .where((task) =>
              task.start != null && DateTime.parse(task.start!).hour == hour)
          .toList();

      Widget timeLabel = Container(
        padding: EdgeInsets.symmetric(
            vertical: 16), // Adjust the space for each hour
        child: Text('${hour.toString().padLeft(2, '0')}:00'),
      );

      List<Widget> taskTiles =
          hourlyTasks.map((task) => buildTaskTile(task)).toList();

      timelineTasks.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(width: 50, child: timeLabel),
              Expanded(child: Column(children: taskTiles)),
            ],
          ),
        ),
      );
    }

    return ListView(children: timelineTasks);
  }

  Widget buildTaskTile(TaskInfo task) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${formatDateTime(task.start)} - ${formatDateTime(task.end)}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown time';
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  String calculateDuration(String? start, String? end) {
    if (start == null || end == null) {
      return 'Duration Unknown';
    }
    DateTime startTime = DateTime.parse(start);
    DateTime endTime = DateTime.parse(end);
    Duration duration = endTime.difference(startTime);
    return "${duration.inHours}h ${duration.inMinutes % 60}m";
  }
}