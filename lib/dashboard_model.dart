import 'package:xml/xml.dart';

class TradeData {
  final int id;
  final int memberId;
  final int erpAccountId;
  final String companyName; //
  final String nickName;
  final DateTime tradeDate;

  ///

  ///
  final DateTime valor;

  ///

  ///
  final int orderType; //
  final String symbol; //
  final double amount; //
  final double requestPrice;
  final double openPrice;
  final double price; //
  final double total; //
  final int statusId; //
  final int erpId;

  TradeData({
    required this.id,
    required this.memberId,
    required this.erpAccountId,
    required this.companyName,
    required this.nickName,
    required this.tradeDate,
    required this.valor,
    required this.orderType,
    required this.symbol,
    required this.amount,
    required this.requestPrice,
    required this.openPrice,
    required this.price,
    required this.total,
    required this.statusId,
    required this.erpId,
  });

  factory TradeData.fromXml(XmlElement xml) {
    return TradeData(
      id: int.parse(xml.findElements('Id').single.text),
      memberId: int.parse(xml.findElements('MemberId').single.text),
      erpAccountId: int.parse(xml.findElements('ERPAccountId').single.text),
      companyName: xml.findElements('CompanyName').single.text,
      nickName: xml.findElements('NickName').single.text,
      tradeDate: DateTime.parse(xml.findElements('TradeDate').single.text),
      valor: DateTime.parse(xml.findElements('Valor').single.text),
      orderType: int.parse(xml.findElements('OrderType').single.text),
      symbol: xml.findElements('Symbol').single.text,
      amount: double.parse(xml.findElements('Amount').single.text),
      requestPrice: double.parse(xml.findElements('RequestPrice').single.text),
      openPrice: double.parse(xml.findElements('OpenPrice').single.text),
      price: double.parse(xml.findElements('Price').single.text),
      total: double.parse(xml.findElements('Total').single.text),
      statusId: int.parse(xml.findElements('StatusId').single.text),
      erpId: int.parse(xml.findElements('ERPID').single.text),
    );
  }
}
