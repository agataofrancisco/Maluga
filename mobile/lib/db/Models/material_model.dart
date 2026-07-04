class Materialmodel {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final String status;
  final double price;

  Materialmodel({
    required this.id,
    required this.name, 
    required this.description,
    required this.quantity,
    required this.status,
    required this.price, 
  });

  factory Materialmodel.fromMap(Map<String, dynamic> json){
    return Materialmodel(
      id: json['id_material'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      status: json['status'] as String, 
      price:( json['price'] as num).toDouble()
    );
  }
  Map<String, dynamic> toMap(){
    return {
      'id':id,
      'name':name,
      'description':description,
      'quantity':quantity,
      'status':status,
      'price':price
    };
  }
}