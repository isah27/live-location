class User {
  static const tbluser = 'user';
  static const colId = 'id';
  static const colName = 'name';
  static const colSwitch = "enableStatus";

  User({
    this.id,
    this.name,
    this.enableStatus,
  });

  User.fromMap(Map<dynamic, dynamic> map) {
    id = map[colId];
    name = map[colName];
    enableStatus = map[colSwitch];
  }

  int? id;
  String? name;
  int? enableStatus;

  Map<String, dynamic> tomap() {
    var map = <String, dynamic>{
      colName: name,
      colSwitch:enableStatus,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
