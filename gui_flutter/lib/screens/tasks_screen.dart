import 'package:antdesign_icons/antdesign_icons.dart';
import 'package:ensety_windows_test/new_task_dialog.dart';
import 'package:ensety_windows_test/providers/jobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  late TaskDataSource taskDataSource;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    tasks = getTaskData();
    var jobsProv = Provider.of<Jobs>(context, listen: false);
    taskDataSource = TaskDataSource(taskData: tasks, jobsProv: jobsProv);
  }

  @override
  Widget build(BuildContext context) {
    var jobsProv = Provider.of<Jobs>(context);
    var jobs = jobsProv.jobs;
    return jobs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 120,
                    child: SvgPicture.asset('assets/images/empty1.svg')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.noJobsLabel} ',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.addNewJobTextButtonLabel,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Color.fromRGBO(20, 142, 255, 1),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (bCtx) {
                              return NewTaskDialog();
                            });
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.tasksAllJobsLabel,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (bCtx) {
                              return NewTaskDialog();
                            });
                      },
                      child: Text(
                        '+ ${AppLocalizations.of(context)!.addNewTaskButtonLabel}',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        backgroundColor: const Color.fromRGBO(24, 144, 255, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                SfDataGrid(
                  source: taskDataSource,
                  columnWidthMode: ColumnWidthMode.fill,
                  columns: [
                    GridColumn(
                        columnName: 'name',
                        label: Container(
                            //color: const Color.fromRGBO(243, 243, 243, 1),
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.taskNameColumn,
                            ))),
                    GridColumn(
                        columnName: 'description',
                        label: Container(
                          //color: const Color.fromRGBO(243, 243, 243, 1),
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(AppLocalizations.of(context)!
                              .taskDescriptionColumn),
                        )),
                    GridColumn(
                        columnName: 'type',
                        label: Container(
                          //color: const Color.fromRGBO(243, 243, 243, 1),
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.taskTypeColumn,
                          ),
                        )),
                    GridColumn(
                        columnName: 'next_launch',
                        label: Container(
                          //color: const Color.fromRGBO(243, 243, 243, 1),
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(AppLocalizations.of(context)!
                              .taskNextLaunchColumn),
                        )),
                    GridColumn(
                        columnName: 'actions',
                        label: Container(
                          //color: const Color.fromRGBO(243, 243, 243, 1),
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              AppLocalizations.of(context)!.taskActionsColumn),
                        )),
                  ],
                ),
              ],
            ),
          );
  }

  List<Task> getTaskData() {
    return Provider.of<Jobs>(context).jobs;
  }
}

class TaskDataSource extends DataGridSource {
  List<DataGridRow> _taskData = [];
  Jobs jobsProv;

  TaskDataSource({required List<Task> taskData, required this.jobsProv}) {
    _taskData = taskData.map((e) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: e.id),
        DataGridCell<String>(columnName: 'name', value: e.name),
        DataGridCell<String>(columnName: 'description', value: e.description),
        DataGridCell<String>(columnName: 'type', value: e.type),
        DataGridCell<String>(
            columnName: 'next_launch',
            value: DateFormat('MM/dd/yyyy kk:mm').format(e.nextLaunch)),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _taskData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    var rowCells = row.getCells();
    String uid = rowCells[0].value as String;
    rowCells.removeAt(0);
    var cellsList = rowCells.map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList();
    cellsList.add(Row(
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Edit',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color.fromRGBO(24, 144, 255, 1),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            jobsProv.removeTaskById(uid);
          },
          child: const Text('Delete',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.red,
              )),
        ),
      ],
    ));
    return DataGridRowAdapter(cells: cellsList);
  }
}
