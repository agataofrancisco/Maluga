
class KilapiModel {
  final int id;
  final String nameKilapeiro;
  final String nifKilapeiro;
  final String contactKilapeiro;
  final String materials;
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
      id:  json['id_kilapi'] as int,
      nameKilapeiro: json['name_kilapeiro'] as String,
      nifKilapeiro: json['nif_kilapeiro'] as String,
      contactKilapeiro: json['contact_kilapeiro'] as String,
      materials:  json['materials']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      datekilapi:  DateTime.tryParse(json['date_kilapi']?.toString() ?? '') ?? DateTime.now(),
      datereturn:  DateTime.tryParse(json['date_return']?.toString() ?? '') ?? DateTime.now(),
      contractImage:  json['contract_image']?.toString() ?? '',
      totalKilapi: (json['total_kilapi'] as num?)?.toDouble() ?? 0.0
    );
  }
}
