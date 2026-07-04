
class AlugoModel {
  final int id_alugo;
  final String name_alugador;
  final String nif_alugador;
  final String contact_alugador;
  final DateTime date_alugo;
  final DateTime date_return;
  final double totalalugo;
  final String contractImage;

    AlugoModel({
      required this.id_alugo,
      required this.name_alugador,
      required this.nif_alugador,
      required this.contact_alugador,
      required this.date_alugo,
      required this.date_return,
      required this.totalalugo,
      required this.contractImage, 
});

  factory AlugoModel.fromMap(Map<String, dynamic> json){
    return AlugoModel(
      id_alugo:  json['id_alugo'] as int, 
      name_alugador: json['name_alugador'] as String, 
      nif_alugador: json['nif_alugador'] as String,
      contact_alugador: json['contact_alugador'] as String,
      date_alugo:  DateTime.tryParse(json['date_alugo']?.toString() ?? '') ?? DateTime.now(),
      date_return:  DateTime.tryParse(json['date_return']?.toString() ?? '') ?? DateTime.now(),
      totalalugo: (json['total_alugo'] as num?)?.toDouble() ?? 0.0,
      contractImage:  json['contract_image']?.toString() ?? '',
    );
  }


}