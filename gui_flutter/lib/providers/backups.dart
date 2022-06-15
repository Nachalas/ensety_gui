import 'package:flutter/material.dart';

enum BackupStatus {
  Success,
  Error,
}

String backupStatusToString(BackupStatus status) {
  switch (status) {
    case BackupStatus.Success:
      return 'Success';
    case BackupStatus.Error:
      return 'Error';
    default:
      return 'Wtf is that status';
  }
}

class Backup {
  String backupId;
  String jobId;
  DateTime time;
  String type;
  int elapsedMs;
  BackupStatus status;

  Backup({
    required this.backupId,
    required this.jobId,
    required this.time,
    required this.type,
    required this.elapsedMs,
    required this.status,
  });
}

class Backups with ChangeNotifier {
  final List<Backup> _backups = [];

  List<Backup> get backups {
    return [..._backups];
  }

  void addNewBackup(Backup newBackup) {
    _backups.add(newBackup);
    notifyListeners();
  }

  void clear() {
    _backups.clear();
    notifyListeners();
  }

  void removeBackupById(String id) {
    _backups.removeWhere((element) => element.backupId == id);
    notifyListeners();
  }
}
