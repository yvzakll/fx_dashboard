import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fx_dashboard/pages/dashboard_screen.dart';
import 'package:fx_dashboard/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hive paketini kullanacaksanız, 'package:hive/hive.dart'; ekleyin.

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController serverIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final ScrollController scrollController = ScrollController();

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverId', serverIdController.text);
    await prefs.setString('userName', userNameController.text);
    await prefs.setString('password', passwordController.text);

    // Hive kullanacaksanız, Hive kutusuna kaydetme işlemini burada yapın.
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferences'den verileri oku
    final serverId = prefs.getString('serverId') ?? '';
    final userName = prefs.getString('userName') ?? '';
    final password = prefs.getString('password') ?? '';

    // Okunan verileri TextEditingControllers ile güncelle
    setState(() {
      serverIdController.text = serverId;
      userNameController.text = userName;
      passwordController.text = password;
    });
  }

  @override
  void initState() {
    super.initState();
    serverIdController.addListener(() {
      final text = serverIdController.text;
      if (text.length > 6) {
        // 6 karakterden fazlaysa, son girilen karakteri sil
        serverIdController.value = serverIdController.value.copyWith(
          text: text.substring(0, 6),
          selection: const TextSelection.collapsed(offset: 6),
        );
      }
    });

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.red.shade900,
            Colors.red.shade800,
            Colors.red.shade400
          ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Image.asset(
                        "assets/fiziki.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                    Text("FX DASHBOARD",
                        style: Theme.of(context).textTheme.headline4)
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        const SizedBox(
                          height: 30,
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromRGBO(224, 38, 13, 0.286),
                                        blurRadius: 20,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextField(
                                      controller: serverIdController,
                                      keyboardType: TextInputType
                                          .number, // Sadece sayısal giriş
                                      decoration: const InputDecoration(
                                          hintText: "Server Id",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextField(
                                      controller: userNameController,
                                      decoration: const InputDecoration(
                                          hintText: "User Name",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText:
                                          !_isPasswordVisible, // Şifre görünürlüğü kontrolü
                                      decoration: InputDecoration(
                                          hintText: "Password",
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          border: InputBorder.none,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              // Şifre görünürlüğüne göre ikon değiştirme
                                              _isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                            onPressed: () {
                                              // Şifre görünürlüğünü değiştir
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(
                          height: 40,
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: MaterialButton(
                              onPressed: () async {
                                await saveData(); // Kullanıcı bilgilerini kaydet

                                // Kullanıcı bilgileri ile API çağrısı yaparak veri çekme
                                TradeDataService service = TradeDataService();
                                service
                                    .fetchTradeData(
                                        serverIdController.text,
                                        userNameController.text,
                                        passwordController.text)
                                    .then((data) {
                                  if (data.isNotEmpty) {
                                    // Veri başarıyla çekildiyse, DashboardScreen'e yönlendir
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                      builder: (context) => DashboardScreen(
                                        serverId: serverIdController.text,
                                        userName: userNameController.text,
                                        password: passwordController.text,
                                      ),
                                    ));
                                  } else {
                                    // Veri çekilemediyse, hata mesajı göster
                                    showError(
                                        "Giriş başarısız. Lütfen bilgilerinizi kontrol edin veya bağlantınızı kontrol edin.");
                                  }
                                }).catchError((error) {
                                  // API çağrısında hata oluşursa
                                  showError(
                                      "Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.");
                                  print(error);
                                });
                              },
                              height: 50,
                              // margin: EdgeInsets.symmetric(horizontal: 50),
                              color: Colors.green[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              // decoration: BoxDecoration(
                              // ),
                              child: const Center(
                                child: Text(
                                  "GİRİŞ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
  void dispose() {
    serverIdController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
