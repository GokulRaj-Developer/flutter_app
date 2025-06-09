import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _dob;
  String? _gender;


  void _submit() {
  if (_formKey.currentState!.validate()) {
    Navigator.pushNamed(
      context,
      '/facial_capture',
      arguments: {
        'firstName': _firstNameController.text.trim(),
      },
    );
  }
}


  Future<void> _selectDOB(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dob = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'First name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Last name is required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_dob == null
                    ? 'Date of Birth (optional)'
                    : 'DOB: ${_dob!.day}/${_dob!.month}/${_dob!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDOB(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender (optional)',
                  border: OutlineInputBorder(),
                ),
                value: _gender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
