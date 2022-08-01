class User {
  static const tbluser = 'user';
  static const colId = 'id';
  static const colName = 'name';

  User({this.id, this.name, });

  User.fromMap(Map<dynamic, dynamic> map) {
    id = map[colId];
    name = map[colName];
   
  }

  int? id;
  String? name;
 
  Map<String, dynamic> tomap() {
    var map = <String, dynamic>{
      colName: name,
     
    };
    if (id != null) map[colId] = id;
    return map;
  }
}