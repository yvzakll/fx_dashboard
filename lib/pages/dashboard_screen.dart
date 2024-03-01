import 'package:flutter/material.dart';
import 'package:fx_dashboard/constants/const.dart';
import 'package:fx_dashboard/models/dashboard_model.dart';
import 'package:fx_dashboard/pages/login_screen.dart';
import 'package:fx_dashboard/services/login_service.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final String serverId;
  final String userName;
  final String password;

  const DashboardScreen(
      {Key? key,
      required this.serverId,
      required this.userName,
      required this.password})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TradeData> tradeDataList = [
    // Test verileriyle örnek TradeData listesi oluştur
    // ...
  ];
  List<TradeData> displayedList = [];

  String selectedSearchCriteria = 'Firma Adı'; // Varsayılan arama kriteri
  final searchCriteria = ['Firma Adı', 'Tarih'];

  /* Future<void> fetchTradeData() async {
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
            <ServerId>${widget.serverId}</ServerId>
            <UserName>${widget.userName}</UserName>
            <Password>${widget.password}</Password>
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
        print(response.statusCode.toString());
        // Handle the response XML
        var document = XmlDocument.parse(response.body);
        // Parse the response as needed
        String responseString = "";
        var elements = document.findAllElements('TradeData');
        setState(() {
          tradeDataList =
              elements.map((node) => TradeData.fromXml(node)).toList();
          displayedList = tradeDataList; // eklendi
        });
        print(responseString.toString());

        if (tradeDataList.isEmpty) {
          showError(
              "Sunucudan Yanıt Alınamadı, Girdiğiniz Bilgileri Kontrol Ediniz");
          print(
              "Failed with status: ${response.statusCode}. Reason: ${response.reasonPhrase}");
        }
      }
    } catch (e) {
      showError("Bir Hata Oluştu. Bilgilerinizi Kontrol Ediniz");
      print(e.toString());
    }
  } */

  @override
  void initState() {
    super.initState();
    TradeDataService()
        .fetchTradeData(widget.serverId, widget.userName, widget.password)
        .then((data) {
      setState(() {
        tradeDataList = data;
        displayedList = tradeDataList;
      });
    }).catchError((error) {
      // Hata yönetimi
      print("Error initializing data: $error");
    }); // Başlangıçta gösterilen liste tam liste olsun
  }

  late List<TradeData> results;
  void filterList(String searchTerm) {
    print("servis çağırıldı");
    if (searchTerm.isEmpty) {
      results = tradeDataList;
    } else if (selectedSearchCriteria == 'Firma Adı') {
      results = tradeDataList
          .where((item) =>
              item.companyName.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    } else if (selectedSearchCriteria == 'Tarih') {
      results = tradeDataList
          .where((item) =>
              DateFormat('dd/MM/yyyy').format(item.tradeDate) == searchTerm)
          .toList();
    }
    setState(() {
      displayedList = results;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Hata mesajı için kırmızı arka plan
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // LoginPage'e geri yönlendir
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
        // false döndürmek, uygulamanın otomatik olarak kapanmasını engeller
        return false;
      },
      child: Scaffold(
        appBar: myAppBar(context),
        body: RefreshIndicator(
          onRefresh: () async {
            TradeDataService()
                .fetchTradeData(
                    widget.serverId, widget.userName, widget.password)
                .then((data) {
              setState(() {
                tradeDataList = data;
                displayedList = tradeDataList;
              });
            }).catchError((error) {
              // Hata yönetimi
              print("Error initializing data: $error");
            });
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    myDropDown(),
                    mySearchInput(),
                  ],
                ),
              ),
              const MyHeaders(),
              MyListView(displayedList: displayedList),
            ],
          ),
        ),
      ),
    );
  }

  AppBar myAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red.shade800,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white70),
      centerTitle: true, // Başlığı merkeze al
      title: Row(
        mainAxisSize: MainAxisSize
            .min, // Row widget'ının sadece içeriğinin genişliğini almasını sağlar
        children: [
          Image.asset(
            "assets/fiziki.png",
            height: 50,
            width: 50,
          ),
          const SizedBox(width: 8), // İkon ve metin arasında biraz boşluk bırak
          Text(
            "FX DASHBOARD",
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Expanded myDropDown() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          backgroundBlendMode: BlendMode.lighten,

          color: Colors.white, // Dropdown arka plan rengi
          borderRadius: BorderRadius.circular(10.0), // Kenar yuvarlaklığı
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // Gölgenin pozisyonunu ayarlar
            ),
          ],
        ),
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        child: DropdownButtonHideUnderline(
          // Alt çizgiyi kaldır
          child: DropdownButton<String>(
            isExpanded: true, // Dropdown'ın genişletilmesi
            value: selectedSearchCriteria,
            style: const TextStyle(fontSize: 14),
            icon: const Icon(Icons.arrow_drop_down,
                color: Colors.blueGrey), // İkonu ve rengini özelleştir
            iconSize: 24, // İkon boyutu
            onChanged: (String? newValue) {
              setState(() {
                selectedSearchCriteria = newValue!;
                displayedList =
                    tradeDataList; // Kriter değiştiğinde listeyi sıfırla
              });
            },
            items: searchCriteria.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.blueGrey)), // Text stilini özelleştir
              );
            }).toList(),
            dropdownColor: Colors.white, // Dropdown menü arka plan rengi
            borderRadius:
                BorderRadius.circular(10), // Dropdown menü kenar yuvarlaklığı
          ),
        ),
      ),
    );
  }

  Expanded mySearchInput() {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.056,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // Gölgenin pozisyonunu ayarlar
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) => filterList(value),
            decoration: InputDecoration(
              filled: true, // Arka plan rengini etkinleştir
              fillColor: Colors.white, // Arka plan rengini beyaz yap
              hintText: "Firma Adı veya Tarihe Göre Arama",
              hintStyle: const TextStyle(fontSize: 14, color: Colors.blueGrey),

              labelStyle: TextStyle(
                  color:
                      Colors.grey.shade800), // Label metin rengini özelleştir
              suffixIcon: const Icon(Icons.search,
                  color: Colors.blueGrey), // İkon rengini özelleştir
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Daha yuvarlak kenarlar
                borderSide: BorderSide.none, // Kenar çizgisini kaldır
              ),
              // Gölge efekti için dış gölge ekle
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHeaders extends StatelessWidget {
  const MyHeaders({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: const Color.fromARGB(255, 233, 248, 255).withOpacity(0.1),
        ),
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("Şirket Adı", style: MyConstants.headers),
                    Text("Tarih", style: MyConstants.headers)
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text("Sembol", style: MyConstants.headers),
                    Text("Miktar", style: MyConstants.headers)
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text("Fiyat", style: MyConstants.headers),
                    Text("Tutar", style: MyConstants.headers)
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text("İşlem Tipi", style: MyConstants.headers),
                    Text("Durum", style: MyConstants.headers)
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyListView extends StatelessWidget {
  const MyListView({
    Key? key,
    required this.displayedList,
  }) : super(key: key);

  final List<TradeData> displayedList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: displayedList.length,
        itemBuilder: (context, index) {
          TradeData data = displayedList[index];
          final itemColor = data.orderType == 1
              ? const Color.fromARGB(174, 216, 240, 229)
              : const Color.fromARGB(
                  255, 255, 225, 223); // Çift için mavi, tek için yeşil
          return Card(
            color: itemColor,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text(data.companyName, style: MyConstants.items),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(DateFormat('dd/MM/yyyy').format(data.tradeDate),
                            style: MyConstants.date)
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text(data.symbol, style: MyConstants.items),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(formatNumber(data.amount),
                            style: MyConstants.items)
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text(formatDecimalNumber(data.price),
                            style: MyConstants.items),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(formatDecimalNumber(data.total),
                            style: MyConstants.items)
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(data.orderType == 1 ? "ALIŞ" : "SATIŞ",
                            style: MyConstants.items),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(data.statusId == 1 ? "OK" : "RED",
                            style: MyConstants.date)
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String formatDecimalNumber(num number) {
  final decimalFormat =
      NumberFormat("#,##0.000", "tr_TR"); // Türkçe için kullanım
  return decimalFormat.format(number);
}

String formatNumber(num number) {
  final numberFormat =
      NumberFormat("#,##0.###", "tr_TR"); // Türkçe için kullanım
  return numberFormat.format(number);
}
