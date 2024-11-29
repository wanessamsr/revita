import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/paciente.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/models/cidade.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';

class FormPacientePage extends StatefulWidget {
  final Paciente? paciente; // Recebe um paciente, caso haja edição

  const FormPacientePage({super.key, this.paciente});

  @override
  _FormPacientePageState createState() => _FormPacientePageState();
}

class _FormPacientePageState extends State<FormPacientePage> {
  final PacienteController _controller = PacienteController();

  String nome = '';
  String cpf = '';
  String email = '';
  String endereco = '';
  String? cidadeId;
  String cep = '';
  String dataNascimento = '';
  List<Cidade> cidadeItems = [];

  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCidades();

    if (widget.paciente != null) {
      final paciente = widget.paciente!;
      nome = paciente.nome;
      cpf = paciente.cpf!;
      email = paciente.email;
      endereco = paciente.endereco!;
      cidadeId = paciente.cidade; // Recebe o ID da cidade
      cep = paciente.cep!;
      dataNascimento = paciente.dataNascimento!;
      _dateController.text = dataNascimento;
    }
  }

  Future<void> _loadCidades() async {
    cidadeItems = await _controller.fetchCidades();
    setState(() {});
  }

  Future<void> _savePaciente() async {
    final paciente = Paciente(
      id: widget.paciente?.id ?? '', // Se for um novo paciente, id estará vazio
      nome: nome,
      cpf: cpf,
      email: email,
      endereco: endereco,
      cidade: cidadeId ?? '',
      cep: cep,
      dataNascimento: dataNascimento,

    );

    if (paciente.id.isEmpty) {
      await _controller.savePaciente(paciente); // Cadastro
    } else {
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
        dataNascimento = _dateController.text;
      });
    }
  }

  Widget buildTextField(String label, Function(String) onChanged, {bool obscureText = false}) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildDropdownField<T>(
      String label, T? value, List<T> items, Function(T?) onChanged, String Function(T) getItemLabel) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(getItemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Cadastro Paciente"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.person, size: 60)),
              SizedBox(height: 20),

              buildTextField('Nome', (text) => nome = text),
              SizedBox(height: 20),

              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              SizedBox(height: 10),

              buildTextField('CPF', (text) => cpf = text),
              SizedBox(height: 10),

              buildTextField('E-mail', (text) => email = text),
              SizedBox(height: 10),

              buildTextField('Endereço', (text) => endereco = text),
              SizedBox(height: 10),

              // Dropdown para cidade
              buildDropdownField<Cidade>(
                  'Cidade',
                  cidadeItems.firstWhere(
                    (item) => item.id == cidadeId,
                    orElse: () => cidadeItems.isNotEmpty ? cidadeItems.first : cidadeItems[0]
                  ),
                  cidadeItems,
                  (newValue) => setState(() => cidadeId = newValue?.id),
                  (Cidade cidade) => cidade.nome),
              SizedBox(height: 10),

              buildTextField('CEP', (text) => cep = text),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _savePaciente,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
