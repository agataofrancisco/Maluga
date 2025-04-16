
class KilapiModel {
  final int id;
  final String nameKilapeiro;
  final int nifKilapeiro;
  final int contactKilapeiro;
  final List materials;
  final int quantity;
  final DateTime datekilapi;
  final DateTime datereturn;
  final double totalKilapi;
  final String contractImage;

  KilapiModel({
    required this.id,
    required this.nameKilapeiro,
    required this.nifKilapeiro,
    required this.contactKilapeiro,
    required this.materials,
    required this.quantity,
    required this.datekilapi,
    required this.datereturn,
    required this.contractImage,
    required this.totalKilapi,
  });

  factory KilapiModel.fromMap(Map<String, dynamic> json){
    return KilapiModel(
      id:  json['id_kilapi'], 
      nameKilapeiro: json['name_kilapeiro'], 
      nifKilapeiro: json['nif_kilapeiro'],
      contactKilapeiro: json['contact_kilapeiro'],
      materials:  json['materials'],
      quantity: json['quantity'],
      datekilapi:  json['date_kilapi'],
      datereturn:  json['date_return'],
      contractImage:  json['contract_image'],
      totalKilapi: json['total_kilapi']
    );
  }
}