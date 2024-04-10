import 'dart:developer';
import 'dart:ffi';

import 'package:dailyspace/custom_classes/taskinfo.dart';
import 'package:dailyspace/google/google_sign_in_manager.dart';
import 'package:dailyspace/google/tasks_service.dart';

import 'package:dailyspace/screens/login_screen.dart';
import 'package:dailyspace/screens/vis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:dailyspace/custom_classes/helper.dart';

class ActivityTracker extends StatefulWidget {
  const ActivityTracker({Key? key}) : super(key: key);

  @override
  _ActivityTrackerState createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<ActivityTracker> {
  late Map<String, TaskInfo> availableActivities;
  late Set<TaskInfo> activeActivities;

  final GoogleSignInAccount? account =
      GoogleSignInManager.instance.googleSignIn.currentUser;

  late List<String> availableCalendars;
  Set<String> selectedCalendars = {};

  @override
  void initState() {
    super.initState();
    availableActivities = {};
    activeActivities = {};
    availableCalendars = [];
    _fetchCalenders();
    _fetchActivities();
  }

  Future<void> _fetchCalenders() async {
    availableCalendars.clear();
    final calendars = await TaskService.fetchCalendars(account);
    setState(() {
      calendars.forEach((title, valie) {
        log(title);
        availableCalendars.add(title);
      });
    });
  }

  Future<void> _fetchActivities() async {
    availableActivities.clear();
    final tasks =
        await TaskService.fetchTasksFromCalendar(account, selectedCalendars);
    log(tasks.toString());
    setState(() {
      tasks.values.forEach((task) {
        availableActivities[task['taskId']] =
            TaskInfo(task['taskId'], task['title'], task['due']);
      });
      log("List of available activities fetched on reload: $availableActivities");
    });
  }

  void _startTask() {
    // Implement functionality for Start Task
  }

  void _endTask() {
    // Implement functionality for End Task
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    double space_between = MediaQuery.of(context).size.height * 0.13;
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
      child: Column(
        children: [
          _buildAppBar(),
          _buildAvailableActivities(),
          SizedBox(
            height: space_between,
          ),
          _build_start_task(),
          SizedBox(
            height: space_between,
          ),
          _build_waiting_to_finish()
        ],
      ),
    );
  }

  void _updateSelectedCalendars(Set<String> newSelectedCalendars) {
    setState(() {
      selectedCalendars = newSelectedCalendars;
    });
  }

  void _openCalendarOverlay() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarOverlayDialog(
          availableCalendars: availableCalendars,
          selectedCalendars: selectedCalendars,
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedCalendars = result as Set<String>;
        });
      }
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Main Activity window",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () async {
            _openCalendarOverlay();
          },
          icon: const Icon(Icons.calendar_month),
          color: Colors.black,
          tooltip: "Chose calendars to fetch events from",
        ),
        IconButton(
          onPressed: () async {
            log("Resyncing");
            await _fetchActivities();
          },
          tooltip: "Sync with Google",
          icon: const Icon(Icons.sync),
          color: Colors.black,
        ),
        IconButton(
          onPressed: () async {
            await GoogleSignInManager.instance.googleSignIn.signOut();
            // Navigate back to login screen
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
          icon: const Icon(Icons.logout),
          color: Colors.black,
        )
      ],
    );
  }

  Widget _buildAvailableActivities() {
    // Calculate the maximum height for the available activities section
    double maxHeight = MediaQuery.of(context).size.height * 0.13;
    return SizedBox(
      height: maxHeight,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 1.0),
            top: BorderSide(color: Colors.black, width: 1.0), // Line below
          ),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: availableActivities.length,
          itemBuilder: (context, index) {
            final task = availableActivities.values.elementAt(index);
            return _buildTaskContainer(task.title, task.due);
          },
        ),
      ),
    );
  }

  Widget _buildTaskContainer(String title, String? due) {
    return Container(
      height: 10,
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            if (due != "") // Check if due date is not empty
              Text(
                TimeFormatter.formatTime(due),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _build_start_task() {
    double width = MediaQuery.of(context).size.width * 0.9;
    return Container(
      width: width,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(10.0)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Start Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 4,
                ),
                Text('It is time to start this task',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: Row(),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Add functionality for the first button
                },
                child: Text('Button 1'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add functionality for the second button
                },
                child: Text('Button 2'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build_waiting_to_finish() {
    double width = MediaQuery.of(context).size.width * 0.9;
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Waiting to finish',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Only display this task if activeActivities is empty
          if (activeActivities.isEmpty) ...[
            SizedBox(height: 16), // Spacing between title and conditional text
            Container(
              alignment: Alignment.center,
              child: Text(
                "Not yet, keep it up",
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtonContainer(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent blue color
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveActivities() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: activeActivities.length,
          itemBuilder: (context, index) {
            final task = activeActivities.elementAt(index);
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 100,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlueAccent, Colors.lightGreenAccent],
              ),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Main Menu'),
            onTap: () {
              // Add functionality for Option 1
            },
          ),
          ListTile(
            title: const Text('Visualization'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptionTwoPage()),
              );
            },
          ),
          // Add more ListTile widgets for additional menu options
        ],
      ),
    );
  }
}

class CalendarOverlayDialog extends StatefulWidget {
  final List<String> availableCalendars;
  final Set<String> selectedCalendars;

  const CalendarOverlayDialog({
    Key? key,
    required this.availableCalendars,
    required this.selectedCalendars,
  }) : super(key: key);

  @override
  _CalendarOverlayDialogState createState() => _CalendarOverlayDialogState();
}

class _CalendarOverlayDialogState extends State<CalendarOverlayDialog> {
  Set<String>? _newSelectedCalendars;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Calendar'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: widget.availableCalendars.length,
          itemBuilder: (context, index) {
            final calendarKey = widget.availableCalendars[index];
            return CheckboxListTile(
              title: Text(calendarKey),
              value: widget.selectedCalendars.contains(calendarKey),
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    if (value) {
                      widget.selectedCalendars.add(calendarKey);
                    } else {
                      widget.selectedCalendars.remove(calendarKey);
                    }
                  }
                });
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _newSelectedCalendars = widget.selectedCalendars;
            Navigator.of(context).pop(_newSelectedCalendars);
          },
          child: Text('OK'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Ensure that _newSelectedCalendars is set to selectedCalendars
    // when the dialog is dismissed
    _newSelectedCalendars = widget.selectedCalendars;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure that _newSelectedCalendars is set to selectedCalendars
    // when the dialog is dismissed
    _newSelectedCalendars = widget.selectedCalendars;
  }

  @override
  void didUpdateWidget(CalendarOverlayDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure that _newSelectedCalendars is set to selectedCalendars
    // when the dialog is dismissed
    _newSelectedCalendars = widget.selectedCalendars;
  }

  @override
  void setState(VoidCallback fn) {
    // Ensure that _newSelectedCalendars is set to selectedCalendars
    // when the dialog is dismissed
    _newSelectedCalendars = widget.selectedCalendars;
    super.setState(fn);
  }
}