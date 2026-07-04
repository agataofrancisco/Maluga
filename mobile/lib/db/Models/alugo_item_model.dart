
class AlugoItemModel {
  final int id_item;
  final int id_alugo;
  final String material;
  final int quantity;
    AlugoItemModel({
      required this.id_item,
      required this.id_alugo,
      required this.material,
      required this.quantity,
});

  factory AlugoItemModel.fromMap(Map<String, dynamic> json){
    return AlugoItemModel(
      id_alugo:  json['id_alugo'], 
      id_item: json['id_item'],
      material: json['material'], 
      quantity: json['quantity'],
    );
  }


}