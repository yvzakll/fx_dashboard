import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dashboard_model.dart'; // Modelinizin yolu doğru olmalıdır

class TradeDataService {
  Future<List<TradeData>> fetchTradeData(
      String serverId, String userName, String password) async {
    List<TradeData> tradeDataList = [];
    var headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'http://tempuri.org/GETDashboard',
    };
    var xmlBody = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                     xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <GETDashboard xmlns="http://tempuri.org/">
            <ServerId>$serverId</ServerId>
            <UserName>$userName</UserName>
            <Password>$password</Password>
          </GETDashboard>
        </soap:Body>
      </soap:Envelope>''';

    try {
      var response = await http.post(
        Uri.parse('http://services.aifasoft.com/traderapi/fxapi.asmx'),
        headers: headers,
        body: xmlBody,
      );

      if (response.statusCode == 200) {
        var document = XmlDocument.parse(response.body);
        var elements = document.findAllElements('TradeData');
        tradeDataList =
            elements.map((node) => TradeData.fromXml(node)).toList();
      } else {
        // Hata yönetimi veya loglama
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      // Hata yönetimi veya loglama
      print("Error fetching data: $e");
    }
    return tradeDataList;
  }
}
