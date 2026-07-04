import 'package:nif_validator/nif_validator.dart';

 Future<String> ValidarNif(String nif) async{
  final validator = NIFValidator();
  final result = await validator.validate(nif);

  if(result.isValid){
    return (result as NIFValidatorResponse).name;
  }else{
    return "Nome não encontrado";
  }
}