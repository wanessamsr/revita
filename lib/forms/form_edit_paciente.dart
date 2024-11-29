import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/paciente.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/models/cidade.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';

class EditarPacientePage extends StatefulWidget {
  final Paciente paciente;

  const EditarPacientePage({super.key, required this.paciente});

  @override
  _EditarPacientePageState createState() => _EditarPacientePageState();
}

class _EditarPacientePageState extends State<EditarPacientePage> {
  final PacienteController _controller = PacienteController();

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _enderecoController = TextEditingController();
  TextEditingController _cepController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  Cidade? cidadeSelecionada;
  String dataNascimento = '';
  List<Cidade> cidadeItems = [];

  @override
  void initState() {
    super.initState();
    _loadCidades();

    _nomeController.text = widget.paciente.nome;
    _cpfController.text = widget.paciente.cpf ?? '';
    _emailController.text = widget.paciente.email ?? '';
    _enderecoController.text = widget.paciente.endereco ?? '';
    _cepController.text = widget.paciente.cep ?? '';
    dataNascimento = widget.paciente.dataNascimento ?? '';
    _dateController.text = dataNascimento;

    _setCidadeSelecionada();
  }

  Future<void> _loadCidades() async {
    cidadeItems = await _controller.fetchCidades();
    _setCidadeSelecionada();
    setState(() {}); 
  }

  void _setCidadeSelecionada() {
    if (cidadeItems.isNotEmpty) {
      cidadeSelecionada = cidadeItems.firstWhere(
        (cidade) => cidade.id == widget.paciente.cidade,
        orElse: () => cidadeItems[0],
      );
    } else {
      cidadeSelecionada = null; 
    }
  }

  Future<void> _savePaciente() async {
    final paciente = Paciente(
      id: widget.paciente.id,
      nome: _nomeController.text,
      cpf: _cpfController.text,
      email: _emailController.text,
      endereco: _enderecoController.text,
      cidade: cidadeSelecionada?.id ?? '', 
      cep: _cepController.text,
      dataNascimento: dataNascimento,
    );

    await _controller.savePaciente(paciente);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paciente atualizado com sucesso!')),
    );
    Navigator.of(context).pop(paciente); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Editar Paciente"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(child: Icon(Icons.person, size: 60)),
              SizedBox(height: 20),

              buildTextField('Nome', _nomeController),
              buildTextField('CPF', _cpfController),
              buildTextField('E-mail', _emailController),
              buildTextField('Endereço', _enderecoController),
              buildTextField('CEP', _cepController),
              buildDateField('Data de Nascimento', _dateController),
              const SizedBox(height: 16.0),

             buildDropdownField<Cidade>(
  'Cidade',
  cidadeSelecionada,
  cidadeItems,
  (value) {
    setState(() {
      cidadeSelecionada = value;
    });
  },
  (cidade) => cidade.nome,
),

              const SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: _savePaciente,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: dataNascimento.isNotEmpty
                ? DateTime.parse(dataNascimento)
                : DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (selectedDate != null) {
            setState(() {
              dataNascimento = selectedDate.toString();
              controller.text = dataNascimento;
            });
          }
        },
      ),
    );
  }

  Widget buildDropdownField<T>(
  String label,
  T? selectedValue,
  List<T> items,
  Function(T?) onChanged,
  String Function(T) getItemLabel,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: DropdownButtonFormField<T>(
      value: selectedValue,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(getItemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

}
