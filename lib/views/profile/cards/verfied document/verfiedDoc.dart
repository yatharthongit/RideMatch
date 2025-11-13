import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifiedDoc extends StatefulWidget {
  const VerifiedDoc({super.key});

  @override
  State<VerifiedDoc> createState() => _VerifiedDocState();
}

class _VerifiedDocState extends State<VerifiedDoc> {
  TextEditingController drivingController = TextEditingController();
  TextEditingController aadharController = TextEditingController();

  File? drivingFile;
  File? aadharFile;

  bool submitDrivingText = true;
  bool submitAadharText = true;

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (type == 'driving') {
          drivingFile = File(result.files.single.path!);
        } else {
          aadharFile = File(result.files.single.path!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        title: Text(
          "Verified Documents",
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600, fontSize: 20,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDocumentCard(
              title: "Driving License",
              controller: drivingController,
              file: drivingFile,
              onPick: () => pickFile('driving'),
              icon: Icons.drive_eta_rounded,
              submitTextOnly: submitDrivingText,
              onToggleSubmitText: (val) {
                setState(() => submitDrivingText = val);
              },
              hintText: "Enter Driving License Number",
              color: Color(0xffAAC4F5),
            ),
            const SizedBox(height: 20),
            _buildDocumentCard(
              title: "Aadhar Card",
              controller: aadharController,
              file: aadharFile,
              onPick: () => pickFile('aadhar'),
              icon: Icons.credit_card_rounded,
              submitTextOnly: submitAadharText,
              onToggleSubmitText: (val) {
                setState(() => submitAadharText = val);
              },
              hintText: "Enter Aadhar Number",
              color: Color(0xffAAC4F5),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                if ((drivingController.text.isEmpty && drivingFile == null) ||
                    (aadharController.text.isEmpty && aadharFile == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Please fill text or upload file for each document")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Documents Submitted Successfully")),
                  );
                }
              },
              icon: const Icon(Icons.upload_file_rounded,color: Colors.white,),
              label: Text(
                "Submit Documents",
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff113F67),
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required TextEditingController controller,
    required File? file,
    required VoidCallback onPick,
    required IconData icon,
    required bool submitTextOnly,
    required Function(bool) onToggleSubmitText,
    required String hintText,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(icon, color: Color(0xff0C2B4E)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.dmSans(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            enabled: submitTextOnly,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black45
                ),
                borderRadius: BorderRadius.circular(14)
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              prefixIcon: Icon(icon, color: Colors.black87, size: 22),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file_rounded, size: 18,color: Colors.white,),
                label: Text(file == null ? "Upload File" : "Change File",
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w500,color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff113F67),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
              if (file != null)
                Flexible(
                  child: Text(
                    "File Selected",
                    style: GoogleFonts.dmSans(
                        color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Submit as Text Only",
                    style:
                    GoogleFonts.dmSans(fontSize: 12, color: Colors.black54),
                  ),
                  Switch(
                    value: submitTextOnly,
                    onChanged: onToggleSubmitText,
                    activeColor: const Color(0xff113F67),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
