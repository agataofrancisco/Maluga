
class AlugoModel {
  final int id_alugo;
  final String name_alugador;
  final int nif_alugador;
  final int contact_alugador;
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
      id_alugo:  json['id_alugo'], 
      name_alugador: json['name_alugador'], 
      nif_alugador: json['nif_alugador'],
      contact_alugador: json['contact_alugador'],
      date_alugo:  json['date_alugo'],
      date_return:  json['date_return'],
      totalalugo: json['total_alugo'],
      contractImage:  json['contract_image'],
    );
  }


}