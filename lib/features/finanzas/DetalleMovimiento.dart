import 'package:flutter/material.dart';
import 'finanzas_screen.dart';

class DetalleMovimiento extends StatefulWidget {
  const DetalleMovimiento({super.key});
  @override
  DetalleMovimientoState createState() => DetalleMovimientoState();
}

class DetalleMovimientoState extends State<DetalleMovimiento> {
  String textField1 = '';
  String textField2 = '';
  String textField3 = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 70),
                          width: double.infinity,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: 44,
                                    width: double.infinity,
                                    child: Image.network(
                                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/4okb2h2s_expires_30_days.png",
                                      fit: BoxFit.fill,
                                    )),
                                IntrinsicHeight(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 28),
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/ih9a9n0p_expires_30_days.png"),
                                          fit: BoxFit.cover),
                                    ),
                                    child: const Column(children: [
                                      Text(
                                        "Detalles de la transacción",
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      const IntrinsicHeight(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(children: [
                            Text(
                              "Cantidad",
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 27),
                          width: double.infinity,
                          child: Column(children: [
                            InkWell(
                              onTap: () {
                                print('Pressed');
                              },
                              child: IntrinsicWidth(
                                child: IntrinsicHeight(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFCAC4D0),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 6, left: 8, right: 8),
                                    child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "\$ 3.300 COP",
                                            style: TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const IntrinsicHeight(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(children: [
                            Text(
                              "Categoría",
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 27),
                          width: double.infinity,
                          child: Column(children: [
                            InkWell(
                              onTap: () {
                                print('Pressed');
                              },
                              child: IntrinsicWidth(
                                child: IntrinsicHeight(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFCAC4D0),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 6, left: 8, right: 8),
                                    child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Transporte",
                                            style: TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const IntrinsicHeight(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(children: [
                            Text(
                              "Fecha",
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 27),
                          width: double.infinity,
                          child: Column(children: [
                            InkWell(
                              onTap: () {
                                print('Pressed');
                              },
                              child: IntrinsicWidth(
                                child: IntrinsicHeight(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFCAC4D0),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 6, left: 8, right: 8),
                                    child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "2 de marzo de 2025",
                                            style: TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const IntrinsicHeight(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(children: [
                            Text(
                              "Hora",
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 192),
                          width: double.infinity,
                          child: Column(children: [
                            InkWell(
                              onTap: () {
                                print('Pressed');
                              },
                              child: IntrinsicWidth(
                                child: IntrinsicHeight(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFCAC4D0),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 6, left: 8, right: 8),
                                    child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "12:15",
                                            style: TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicWidth(
                        child: IntrinsicHeight(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 19, left: 47),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicWidth(
                                    child: IntrinsicHeight(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: const Color(0xFFE8DEF8),
                                        ),
                                        padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 16,
                                            right: 16),
                                        margin:
                                            const EdgeInsets.only(right: 77),
                                        child: Row(children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              width: 18,
                                              height: 18,
                                              child: Image.network(
                                                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/hdkw0zma_expires_30_days.png",
                                                fit: BoxFit.fill,
                                              )),
                                          IntrinsicHeight(
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 35,
                                              child: TextField(
                                                style: const TextStyle(
                                                  color: Color(0xFF4A4459),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    textField1 = value;
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: "Editar",
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 0),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                  IntrinsicWidth(
                                    child: IntrinsicHeight(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: const Color(0xFFE8DEF8),
                                        ),
                                        padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 16,
                                            right: 16),
                                        child: Row(children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              width: 18,
                                              height: 18,
                                              child: Image.network(
                                                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/ng6gs9mg_expires_30_days.png",
                                                fit: BoxFit.fill,
                                              )),
                                          IntrinsicHeight(
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 50,
                                              child: TextField(
                                                style: const TextStyle(
                                                  color: Color(0xFF4A4459),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    textField2 = value;
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: "Eliminar",
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 0),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 19),
                          width: double.infinity,
                          child: Column(children: [
                            IntrinsicWidth(
                              child: IntrinsicHeight(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: const Color(0xFFE8DEF8),
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 16, right: 16),
                                  child: Row(children: [
                                    Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 18,
                                        height: 18,
                                        child: Image.network(
                                          "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/fnb4ead6_expires_30_days.png",
                                          fit: BoxFit.fill,
                                        )),
                                    IntrinsicHeight(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 39,
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navega a la pantalla de finanzas
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const FinanzasScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Volver",
                                            style: TextStyle(
                                              color: Color(0xFF4A4459),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          padding: const EdgeInsets.only(top: 21, bottom: 8),
                          width: double.infinity,
                          child: Column(children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: const Color(0xFF000000),
                              ),
                              width: 134,
                              height: 5,
                              child: const SizedBox(),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
