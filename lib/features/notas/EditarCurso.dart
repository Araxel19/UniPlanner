import 'package:flutter/material.dart';

class EditarCurso extends StatefulWidget {
  const EditarCurso({super.key});

  @override
  EditarCursoState createState() => EditarCursoState();
}

class EditarCursoState extends State<EditarCurso> {
  String textField1 = '';
  String textField2 = '';

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
        title: const Text('Editar Curso'), // Título de la AppBar
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
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/fb19w0dr_expires_30_days.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 9, bottom: 9, left: 20, right: 20),
                            margin: const EdgeInsets.only(bottom: 40),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: Image.network(
                                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/ig81gyh5_expires_30_days.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const Text(
                                  "Ingrese tu nuevo curso",
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicWidth(
                          child: IntrinsicHeight(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 16, left: 33),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: const Text(
                                      "Materia",
                                      style: TextStyle(
                                        color: Color(0xFF1E1E1E),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFD9D9D9),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                    width: 298,
                                    height: 40,
                                    child: const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IntrinsicWidth(
                          child: IntrinsicHeight(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 5, left: 35),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    child: const Text(
                                      "Etiquetas",
                                      style: TextStyle(
                                        color: Color(0xFF1E1E1E),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 13,
                                    height: 13,
                                    child: Image.network(
                                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/yqhogkzc_expires_30_days.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ],
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
                                    color: const Color(0xFFCAC4D0),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 6, bottom: 6, left: 16, right: 16),
                                margin: const EdgeInsets.only(
                                    bottom: 381, left: 33),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 11),
                                      child: const Text(
                                        "Muy dificil",
                                        style: TextStyle(
                                          color: Color(0xFF1D1B20),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      child: Image.network(
                                        "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/mi4dzf2r_expires_30_days.png",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            width: double.infinity,
                            child: Column(
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
                                          left: 32,
                                          right: 32),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(right: 4),
                                            width: 18,
                                            height: 17,
                                            child: Image.network(
                                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/urmq0703_expires_30_days.png",
                                              fit: BoxFit.fill,
                                            ),
                                          ),
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
                                                    textField1 = value;
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
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
                            margin: const EdgeInsets.only(bottom: 32),
                            width: double.infinity,
                            child: Column(
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
                                          top: 9,
                                          bottom: 9,
                                          left: 56,
                                          right: 56),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            child: Image.network(
                                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/rL97OYSa4e/efrjwq8l_expires_30_days.png",
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 1),
                                              width: 49,
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
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: "Guardar",
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 0),
                                                  border: InputBorder.none,
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
