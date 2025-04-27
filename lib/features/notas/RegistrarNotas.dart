import 'package:flutter/material.dart';

class RegistrarNotas extends StatefulWidget {
  const RegistrarNotas({super.key});

  @override
  RegistrarNotasState createState() => RegistrarNotasState();
}

class RegistrarNotasState extends State<RegistrarNotas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Flecha de retroceso
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
        title: const Text('Registrar Notas'), // Título de la AppBar
        backgroundColor: Colors.blueAccent, // Color de fondo de la AppBar
      ),
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
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          height: 44,
                          width: double.infinity,
                          child: Image.network(
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/358vd1ka_expires_30_days.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 17, right: 106),
                            margin: const EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: Image.network(
                                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/cualxzvz_expires_30_days.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Registre tus notas",
                                          style: TextStyle(
                                            color: const Color(0xFF000000),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Por corte",
                                          style: TextStyle(
                                            color: const Color(0xFF000000),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFCAC4D0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFEF7FF),
                            ),
                            padding: const EdgeInsets.only(top: 82, bottom: 16),
                            margin: const EdgeInsets.only(
                                bottom: 13, left: 19, right: 19),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 4, left: 16),
                                  child: Text(
                                    "Nota :",
                                    style: TextStyle(
                                      color: const Color(0xFF000000),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFCAC4D0),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.only(left: 14),
                                  width: 117,
                                  height: 32,
                                  child: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFCAC4D0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFEF7FF),
                            ),
                            padding: const EdgeInsets.only(top: 77, bottom: 18),
                            margin: const EdgeInsets.only(
                                bottom: 13, left: 19, right: 19),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 6, left: 16),
                                  child: Text(
                                    "Nota :",
                                    style: TextStyle(
                                      color: const Color(0xFF000000),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFCAC4D0),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.only(left: 14),
                                  width: 117,
                                  height: 32,
                                  child: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFCAC4D0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFEF7FF),
                            ),
                            padding: const EdgeInsets.only(top: 77, bottom: 18),
                            margin: const EdgeInsets.only(
                                bottom: 12, left: 18, right: 18),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 6, left: 17),
                                  child: Text(
                                    "Nota :",
                                    style: TextStyle(
                                      color: const Color(0xFF000000),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFCAC4D0),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.only(left: 15),
                                  width: 117,
                                  height: 32,
                                  child: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFCAC4D0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFEF7FF),
                            ),
                            padding: const EdgeInsets.only(top: 67, bottom: 28),
                            margin: const EdgeInsets.only(
                                bottom: 12, left: 19, right: 19),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IntrinsicWidth(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 5, left: 16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 2, bottom: 2, right: 142),
                                            child: Text(
                                              "Nota final",
                                              style: TextStyle(
                                                color: const Color(0xFF1D1B20),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Nota restante",
                                            style: TextStyle(
                                              color: const Color(0xFF1D1B20),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              print('Pressed');
                                            },
                                            child: IntrinsicWidth(
                                              child: IntrinsicHeight(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFCAC4D0),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6,
                                                          bottom: 6,
                                                          left: 16,
                                                          right: 16),
                                                  margin: const EdgeInsets.only(
                                                      right: 138),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Nota",
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF1D1B20),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              print('Pressed');
                                            },
                                            child: IntrinsicWidth(
                                              child: IntrinsicHeight(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFCAC4D0),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6,
                                                          bottom: 6,
                                                          left: 16,
                                                          right: 16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Nota",
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF1D1B20),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            padding: const EdgeInsets.only(top: 21, bottom: 8),
                            width: double.infinity,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: const Color(0xFF000000),
                                  ),
                                  width: 134,
                                  height: 5,
                                  child: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
