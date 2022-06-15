import 'package:antdesign_icons/antdesign_icons.dart';
import 'package:ensety_windows_test/providers/backups.dart';
import 'package:ensety_windows_test/providers/jobs.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:uuid/uuid.dart';

class BackupLogScreen extends StatefulWidget {
  const BackupLogScreen({Key? key}) : super(key: key);

  @override
  State<BackupLogScreen> createState() => _BackupLogScreenState();
}

class _BackupLogScreenState extends State<BackupLogScreen> {
  late BackupDataSource backupDataSource;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var backupsProv = Provider.of<Backups>(context, listen: false);
    var jobsProv = Provider.of<Jobs>(context, listen: false);
    backupDataSource = BackupDataSource(
      backupData: backupsProv.backups,
      jobsProv: jobsProv,
      backupsProv: backupsProv,
    );
  }

  void _populateBackups() {
    var backupsProv = Provider.of<Backups>(context, listen: false);
    var jobsProv = Provider.of<Jobs>(context, listen: false);
    var jobs = jobsProv.jobs;
    print(jobs.length);

    var rng = Random();

    for (var job in jobs) {
      backupsProv.addNewBackup(Backup(
        backupId: const Uuid().v4(),
        jobId: job.id,
        time: DateTime.now(),
        type: 'Manual',
        elapsedMs: rng.nextInt(100) + 5,
        status: BackupStatus.Success,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var backupsProv = Provider.of<Backups>(context);
    var backups = backupsProv.backups;

    return backups.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 120,
                    child: SvgPicture.asset('assets/images/empty1.svg')),
                Text(
                  '${AppLocalizations.of(context)!.noBackupsLabel} ',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _populateBackups();
                  },
                  icon: const Icon(AntIcons.reloadOutlined),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Column(children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.allBackupsLabel,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      backupsProv.clear();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.clearBackupLogLabel,
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
                      backgroundColor: const Color.fromRGBO(229, 24, 36, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(AntIcons.reloadOutlined),
                  ),
                ],
              ),
              SfDataGrid(
                source: backupDataSource,
                columnWidthMode: ColumnWidthMode.fill,
                columns: [
                  GridColumn(
                      columnName: 'time',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      label: Container(
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              AppLocalizations.of(context)!.backupsTimeLabel))),
                  GridColumn(
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      columnName: 'job_name',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.centerLeft,
                        child:
                            Text(AppLocalizations.of(context)!.backupsJobLabel),
                      )),
                  GridColumn(
                      columnName: 'type',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            AppLocalizations.of(context)!.backupsTypeLabel),
                      )),
                  GridColumn(
                      columnName: 'elapsed_ms',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            AppLocalizations.of(context)!.backupsElapsedLabel),
                      )),
                  GridColumn(
                      columnName: 'status',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            AppLocalizations.of(context)!.backupsStatusLabel),
                      )),
                  GridColumn(
                      columnName: 'actions',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            AppLocalizations.of(context)!.backupsActionsLabel),
                      )),
                ],
              ),
            ]),
          );
  }
}

class BackupDataSource extends DataGridSource {
  List<DataGridRow> _backupData = [];
  Jobs jobsProv;
  Backups backupsProv;

  BackupDataSource({
    required List<Backup> backupData,
    required this.jobsProv,
    required this.backupsProv,
  }) {
    _backupData = backupData.map((e) {
      Task taskInfo = jobsProv.getTaskInfoById(e.jobId);
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'backup_id', value: e.backupId),
        DataGridCell<String>(columnName: 'job_id', value: e.jobId),
        DataGridCell<String>(
            columnName: 'time',
            value: DateFormat('MM/dd/yyyy kk:mm').format(e.time)),
        DataGridCell<String>(columnName: 'job_name', value: taskInfo.name),
        DataGridCell<String>(columnName: 'type', value: e.type),
        DataGridCell<String>(
            columnName: 'elapsed_ms', value: e.elapsedMs.toString()),
        DataGridCell<String>(
            columnName: 'status', value: backupStatusToString(e.status)),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _backupData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    var rowCells = row.getCells();
    String uid = rowCells[0].value as String;
    rowCells.removeRange(0, 2);
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
            'Repeat',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color.fromRGBO(24, 144, 255, 1),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            backupsProv.removeBackupById(uid);
          },
          child: const Text('Remove',
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
