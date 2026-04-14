import '../database.dart';

class UserNotificationsTable extends SupabaseTable<UserNotificationsRow> {
  @override
  String get tableName => 'user_notifications';

  @override
  UserNotificationsRow createRow(Map<String, dynamic> data) =>
      UserNotificationsRow(data);
}

class UserNotificationsRow extends SupabaseDataRow {
  UserNotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserNotificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get playerId => getField<String>('player_id')!;
  set playerId(String value) => setField<String>('player_id', value);

  String? get deviceType => getField<String>('device_type');
  set deviceType(String? value) => setField<String>('device_type', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
