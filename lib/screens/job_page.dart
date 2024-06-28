import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/widgets/job_post.dart';

class JobPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  // Define email domains
  final List<String> emailDomains = [
    '@gmail.com',
    '@yahoo.com',
    '@outlook.com'
  ];

  // Initialize selected domain
  String selectedDomain = '@gmail.com';

  JobPage({Key? key, required this.userData}) : super(key: key);

  Future<void> addJob(
      BuildContext context,
      String jobName,
      String jobText,
      String jobEmail,
      String jobTelNo,
      DateTime? jobBaslangicTarih,
      DateTime? jobBitisTarih) async {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      if (userData['user_id'] == '2') {
        try {
          String jobId = FirebaseFirestore.instance.collection('job').doc().id;
          DateTime currentDate = DateTime.now();
          Map<String, dynamic> jobData = {
            'job_name': jobName,
            'job_text': jobText,
            'user_id': userData['user_id'],
            'date': currentDate,
            'job_email': jobEmail,
            'job_telno': jobTelNo,
            'job_baslangic_tarih': jobBaslangicTarih,
            'job_bitis_tarih': jobBitisTarih,
            'onay_durumu': '1', // Onay durumu
            'aktiflik_durumu': '1', // Aktiflik durumu
          };

          await FirebaseFirestore.instance
              .collection('job')
              .doc(jobId)
              .set(jobData);

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('İş ilanı başarıyla eklendi.'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print("Error adding job: $e");
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('İş ilanı eklenirken bir hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Sadece admin tarafından bu işlem yapılabilir.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> showAddJobPostSheet(BuildContext context) async {
    String jobName = '';
    String jobText = '';
    String jobEmail = '';
    String jobTelNo = '';
    DateTime? jobBaslangicTarih;
    DateTime? jobBitisTarih;

    TextEditingController _phoneNumberController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height * (3.5 / 5),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            onChanged: (value) => jobName = value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'İlan Adı',
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onChanged: (value) => jobText = value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'İlan Metni',
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      onChanged: (value) =>
                                          jobEmail = value + selectedDomain,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'İlan E-mail',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors
                                            .black), // Adjust border color
                                    borderRadius: BorderRadius.circular(
                                        5), // Adjust border radius
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedDomain,
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setModalState(() {
                                          selectedDomain = value;
                                        });
                                      }
                                    },
                                    items: emailDomains
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    style: TextStyle(
                                        color: Colors.black, // Text color
                                        fontSize: 16, // Font size
                                        fontWeight: FontWeight.w500),
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconEnabledColor: Colors.black,
                                    iconSize: 24,
                                    elevation: 8,
                                    dropdownColor:
                                        Color.fromARGB(255, 199, 217, 244),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 7, horizontal: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(11)
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Telefon No',
                                  hintText: 'Lütfen telefon numaranızı giriniz',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen telefon numaranızı giriniz';
                                  } else if (value.length != 11) {
                                    return 'Telefon numarası 11 haneli olmalıdır';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 5),
                              Text(
                                (_phoneNumberController.text.length != 11 &&
                                        _phoneNumberController.text.isNotEmpty)
                                    ? 'Lütfen 11 haneli telefon numarası giriniz'
                                    : '',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Color.fromARGB(255, 44, 2, 13),
                                    elevation: 12.0,
                                  ),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null)
                                      setModalState(() {
                                        jobBaslangicTarih = picked;
                                      });
                                  },
                                  child: Text(
                                    jobBaslangicTarih != null
                                        ? 'Başlangıç Tarihi: ${DateFormat('dd/MM/yyyy').format(jobBaslangicTarih!)}'
                                        : 'Başlangıç Tarihini Seçin',
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Color.fromARGB(255, 44, 2, 13),
                                    elevation: 12.0,
                                  ),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null)
                                      setModalState(() {
                                        jobBitisTarih = picked;
                                      });
                                  },
                                  child: Text(
                                    jobBitisTarih != null
                                        ? 'Bitiş Tarihi: ${DateFormat('dd/MM/yyyy').format(jobBitisTarih!)}'
                                        : 'Bitiş Tarihini Seçin',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.black, // background (button) color
                              foregroundColor:
                                  Colors.white, // foreground (text) color
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the showModalBottomSheet
                              if (_phoneNumberController.text.length == 11 &&
                                  jobName.isNotEmpty &&
                                  jobText.isNotEmpty &&
                                  jobEmail.isNotEmpty &&
                                  jobBaslangicTarih != null &&
                                  jobBitisTarih != null) {
                                // iş ilanı ekleme fonksiyonunu çağır
                                addJob(
                                  context,
                                  jobName,
                                  jobText,
                                  jobEmail,
                                  _phoneNumberController.text,
                                  jobBaslangicTarih,
                                  jobBitisTarih,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Lütfen tüm alanları doğru bir şekilde doldurun.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text('Ekle'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("job")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final jobPost = snapshot.data!.docs[index];
              return JobPost(
                  jobName: jobPost['job_name'],
                  jobText: jobPost['job_text'],
                  jobId: jobPost.id,
                  userData: userData,
                  jobMail: jobPost['job_email'],
                  jobTelNo: jobPost['job_telno'],
                  jobBaslangicTarihi: jobPost['job_baslangic_tarih'],
                  jobBitisTarihi: jobPost['job_bitis_tarih'],
                  jobDate: jobPost['date']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userData['user_id'] == '2' || userData['user_id'] == '1') {
            showAddJobPostSheet(context);
          } else {
            final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
            scaffoldMessenger?.showSnackBar(
              SnackBar(
                content: Text('Sadece admin tarafından bu işlem yapılabilir.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Icon(
          Icons.add,
          color: const Color.fromARGB(255, 4, 4, 2),
        ),
        backgroundColor: Color.fromARGB(131, 130, 170, 202),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
